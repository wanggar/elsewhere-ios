import Foundation

struct SoundLibrary: Equatable {
    var sounds: [SavedSound]
    var activeMode: CuratorMode

    static let initial = SoundLibrary(sounds: [], activeMode: .sleep)

    var activeSound: SavedSound? {
        sounds.last { $0.mode == activeMode }
    }

    var soundCount: Int {
        sounds.count
    }

    var pendingModes: [CuratorMode] {
        CuratorMode.allCases.filter { $0 != activeMode }
    }

    func sounds(for mode: CuratorMode) -> [SavedSound] {
        sounds.filter { $0.mode == mode }
    }

    var activeModeSounds: [SavedSound] {
        sounds(for: activeMode)
    }

    var otherSavedModeGroups: [(mode: CuratorMode, sounds: [SavedSound])] {
        CuratorMode.allCases
            .filter { $0 != activeMode && !sounds(for: $0).isEmpty }
            .map { ($0, sounds(for: $0)) }
    }

    var modesRemainingCount: Int {
        CuratorMode.allCases.filter { sounds(for: $0).isEmpty }.count
    }

    var statusText: String {
        let soundLabel = soundCount == 1 ? "sound" : "sounds"
        let modeWord = modesRemainingCount == 1 ? "mode" : "modes"
        return "\(soundCount) \(soundLabel) · \(modesRemainingCount) \(modeWord) to go"
    }

    mutating func add(_ sound: SavedSound) {
        sounds.append(sound)
        activeMode = sound.mode
    }

    mutating func delete(_ sound: SavedSound) {
        SoundFileStore.delete(fileName: sound.audioFileName)
        sounds.removeAll { $0.id == sound.id }

        if !sounds(for: activeMode).isEmpty {
            return
        }

        if let fallback = sounds.last {
            activeMode = fallback.mode
        }
    }

    mutating func deleteActiveSound() {
        guard let current = activeSound else { return }
        delete(current)
    }
}
