import Foundation

struct SoundInsight: Equatable, Codable, Sendable {
    let headline: String
    let memory: String
    let layers: String
    let connection: String
}

enum SoundInsightService {
    private static let cacheKeyPrefix = "elsewhere.soundInsight."

    static func insight(for sound: SavedSound) async -> SoundInsight {
        // Always rebuild from the latest conversation memory so personal details stay fresh.
        // (Cache is only used as a short-circuit when memory is unchanged.)
        let memory = ConversationMemoryStore.load(for: sound.id)
        let fingerprint = cacheFingerprint(sound: sound, memory: memory)

        if let cached = loadCached(for: sound.id, fingerprint: fingerprint) {
            return cached
        }

        if let remote = try? await fetchRemote(for: sound, memory: memory) {
            saveCached(remote, for: sound.id, fingerprint: fingerprint)
            return remote
        }

        try? await Task.sleep(for: .milliseconds(500))
        let local = composeLocal(for: sound, memory: memory)
        saveCached(local, for: sound.id, fingerprint: fingerprint)
        return local
    }

    // MARK: - Remote

    private struct RequestBody: Encodable {
        let mode: String
        let title: String
        let subtitle: String
        let generationPrompt: String?
        let userLines: [String]
        let agentLines: [String]
    }

    private struct ResponseBody: Decodable {
        let headline: String
        let memory: String
        let layers: String
        let connection: String
    }

    private static func fetchRemote(
        for sound: SavedSound,
        memory: ConversationMemoryStore.Memory?
    ) async throws -> SoundInsight {
        let body = try JSONEncoder().encode(
            RequestBody(
                mode: sound.mode.rawValue,
                title: sound.title,
                subtitle: sound.subtitle,
                generationPrompt: sound.generationPrompt,
                userLines: memory?.userLines ?? [],
                agentLines: memory?.agentLines ?? []
            )
        )
        let data = try await APIClient.request(
            url: APIConfig.soundInsightURL,
            method: "POST",
            body: body
        )
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        return SoundInsight(
            headline: decoded.headline,
            memory: decoded.memory,
            layers: decoded.layers,
            connection: decoded.connection
        )
    }

    // MARK: - Local composition

    private static func composeLocal(
        for sound: SavedSound,
        memory: ConversationMemoryStore.Memory?
    ) -> SoundInsight {
        let details = PersonalDetails.extract(from: memory, sound: sound)

        if details.hasPersonalContent {
            return composePersonal(sound: sound, details: details)
        }
        return composeGeneral(sound: sound)
    }

    private static func composePersonal(sound: SavedSound, details: PersonalDetails) -> SoundInsight {
        let quotedBits = details.notablePhrases.prefix(2).map { "“\($0)”" }.joined(separator: " · ")
        let place = details.place ?? sound.title
        let people = details.people.isEmpty ? nil : details.people.joined(separator: " and ")
        let senses = details.sensory.isEmpty
            ? parseLayers(from: sound.subtitle)
            : details.sensory

        let memoryBody: String = {
            var parts: [String] = []
            parts.append("In your chat you brought us to \(place).")
            if let people {
                parts.append("\(people.capitalizedFirst) showed up in what you shared — that matters here.")
            }
            if !quotedBits.isEmpty {
                parts.append("You said \(quotedBits), and that’s the thread this sound follows.")
            } else if let mood = details.mood {
                parts.append("The feeling you named — \(mood) — is what we’re protecting in the loop.")
            }
            parts.append("This isn’t a stock soundscape. It’s a reconstruction of what you told your curator.")
            return parts.joined(separator: " ")
        }()

        let layerList = senses.prefix(4).joined(separator: ", ")
        let layersBody = layerList.isEmpty
            ? "Inside “\(sound.title)” are the textures your conversation pointed toward — quiet cues your body already recognizes."
            : "From what you described, the mix leans on \(layerList). Those aren’t random textures — they’re the details you gave, turned into something you can hear."

        let connectionBody = """
        Your curator listened first, then built this for \(sound.mode.displayTitle). \
        \(sound.mode.insightRelocationPhrase) \
        Hit play and you’re not escaping — you’re returning to the place you already described.
        """

        return SoundInsight(
            headline: "from what you told your curator",
            memory: memoryBody,
            layers: layersBody,
            connection: connectionBody
        )
    }

    private static func composeGeneral(sound: SavedSound) -> SoundInsight {
        let layers = parseLayers(from: sound.subtitle)
        let layerSentence = layers.isEmpty
            ? "soft ambient texture shaped around \(sound.title)"
            : layers.joined(separator: ", ")

        return SoundInsight(
            headline: "why this one fits \(sound.mode.displayTitle)",
            memory: """
            “\(sound.title)” is a quiet place to land. \
            You didn’t leave many personal breadcrumbs in the chat, so this one stays gentle and open — \
            a room you can step into without needing a whole story first.
            """,
            layers: """
            Inside the loop: \(layerSentence). \
            Soft layers meant to support \(sound.mode.insightModePhrase), without asking much of you.
            """,
            connection: """
            Elsewhere still relocates you — just lightly. \
            \(sound.mode.insightRelocationPhrase) \
            If you chat again and share more details, future sounds can hold those memories more tightly.
            """
        )
    }

    private static func parseLayers(from subtitle: String) -> [String] {
        subtitle
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Cache

    private struct CachedInsight: Codable {
        let fingerprint: String
        let insight: SoundInsight
    }

    private static func cacheFingerprint(
        sound: SavedSound,
        memory: ConversationMemoryStore.Memory?
    ) -> String {
        let userJoin = memory?.userLines.joined(separator: "|") ?? ""
        return "\(sound.id.uuidString)|\(sound.title)|\(sound.subtitle)|\(userJoin)"
    }

    private static func loadCached(for id: UUID, fingerprint: String) -> SoundInsight? {
        guard let data = UserDefaults.standard.data(forKey: cacheKeyPrefix + id.uuidString),
              let cached = try? JSONDecoder().decode(CachedInsight.self, from: data),
              cached.fingerprint == fingerprint
        else { return nil }
        return cached.insight
    }

    private static func saveCached(_ insight: SoundInsight, for id: UUID, fingerprint: String) {
        let payload = CachedInsight(fingerprint: fingerprint, insight: insight)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyPrefix + id.uuidString)
    }
}

// MARK: - Detail extraction from conversation

private struct PersonalDetails {
    var place: String?
    var people: [String] = []
    var sensory: [String] = []
    var mood: String?
    var notablePhrases: [String] = []

    var hasPersonalContent: Bool {
        place != nil
            || !people.isEmpty
            || !sensory.isEmpty
            || mood != nil
            || !notablePhrases.isEmpty
    }

    static func extract(
        from memory: ConversationMemoryStore.Memory?,
        sound: SavedSound
    ) -> PersonalDetails {
        var details = PersonalDetails()
        guard let memory, !memory.userLines.isEmpty else {
            // Fall back to generation prompt / subtitle crumbs if present.
            details.sensory = sound.subtitle
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if let prompt = sound.generationPrompt, prompt.count > 40 {
                details.notablePhrases = [String(prompt.prefix(120))]
            }
            // Subtitle-only isn't enough to call "personal conversation"
            // unless the prompt clearly reflects a chat.
            if details.notablePhrases.isEmpty {
                details.sensory = []
            }
            return details
        }

        let text = memory.rawUserText
        let lower = text.lowercased()

        // Places / settings
        let placeHints = [
            "kitchen", "bedroom", "living room", "bathroom", "hallway", "attic",
            "basement", "porch", "balcony", "garden", "yard", "park", "beach",
            "forest", "train", "bus", "car", "office", "classroom", "cafe",
            "café", "library", "church", "temple", "apartment", "house", "home",
            "window", "street", "city", "village", "grandma", "grandpa", "ama",
            "a-ma", "dorm", "hotel", "airport",
        ]
        for hint in placeHints {
            if lower.contains(hint) {
                details.place = hint
                break
            }
        }
        if details.place == nil, sound.title.count > 2 {
            details.place = sound.title
        }

        // People
        let peopleHints = [
            "mom", "dad", "mother", "father", "sister", "brother", "grandma",
            "grandpa", "ama", "a-ma", "partner", "boyfriend", "girlfriend",
            "wife", "husband", "friend", "roommate", "baby", "kid", "child",
            "dog", "cat",
        ]
        for hint in peopleHints where lower.contains(hint) {
            details.people.append(hint)
        }
        details.people = Array(Set(details.people)).sorted()

        // Sensory
        let sensoryHints = [
            "rain", "heater", "fan", "wind", "birds", "traffic", "clock",
            "kettle", "page", "typing", "hum", "crackl", "whisper", "laugh",
            "tv", "radio", "dishwasher", "washer", "thunder", "snow", "cicada",
            "cricket", "ocean", "waves", "footstep", "door", "fridge",
        ]
        for hint in sensoryHints where lower.contains(hint) {
            details.sensory.append(hint)
        }
        // Blend with subtitle layers
        let subtitleLayers = sound.subtitle
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        details.sensory = Array(Set(details.sensory + subtitleLayers)).sorted()

        // Mood
        let moodHints = [
            "calm", "anxious", "lonely", "safe", "warm", "cold", "tired",
            "peaceful", "nostalgic", "homesick", "cozy", "quiet", "overwhelmed",
            "stressed", "happy", "sad", "settled",
        ]
        for hint in moodHints where lower.contains(hint) {
            details.mood = hint
            break
        }

        // Keep short, concrete user phrases (not whole paragraphs)
        details.notablePhrases = memory.userLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { (12...90).contains($0.count) }
            .prefix(3)
            .map { $0 }

        return details
    }
}

private extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}

private extension CuratorMode {
    var insightModePhrase: String {
        switch self {
        case .sleep: "sleep — soft, unhurried, safe"
        case .focus: "focus — steady, clear, undistracted"
        case .relax: "rest — low pressure, easy breath"
        case .uplift: "a gentle lift — warm without forcing it"
        case .move: "motion — forward, rhythmic, alive"
        }
    }

    var insightRelocationPhrase: String {
        switch self {
        case .sleep:
            "It takes you somewhere your nervous system already trusts, so sleep can arrive on its own."
        case .focus:
            "It parks you in a room where concentration already happened once — so your brain can find that door again."
        case .relax:
            "It puts you back in the afterglow of a long day, where nothing needs solving."
        case .uplift:
            "It borrows the tone of a kinder morning and places it under your feet."
        case .move:
            "It syncs you to a route you’ve walked before, so your body remembers how to keep going."
        }
    }
}
