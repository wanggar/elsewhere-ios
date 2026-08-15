import Foundation

struct SavedSound: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let mode: CuratorMode
    /// Remote signed URL from Supabase Storage. Nil until the save round-trip completes.
    let audioURL: URL?
    /// Optional ElevenLabs generation prompt — used to enrich "what's in this".
    let generationPrompt: String?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        mode: CuratorMode,
        audioURL: URL? = nil,
        generationPrompt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.mode = mode
        self.audioURL = audioURL
        self.generationPrompt = generationPrompt
    }

    static let `default` = SavedSound(
        title: "the living room",
        subtitle: "heater settling, the page turning",
        mode: .sleep
    )

    var categoryLabel: String {
        mode.categoryLabel
    }

    var immersiveDescription: String {
        subtitle
    }
}
