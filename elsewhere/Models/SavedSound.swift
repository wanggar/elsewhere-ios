import Foundation

struct SavedSound: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let mode: CuratorMode
    let audioFileName: String?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        mode: CuratorMode,
        audioFileName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.mode = mode
        self.audioFileName = audioFileName
    }

    static let `default` = SavedSound(
        title: "the living room",
        subtitle: "heater settling, the page turning",
        mode: .sleep
    )

    var audioURL: URL? {
        SoundFileStore.url(for: audioFileName)
    }

    var categoryLabel: String {
        mode.categoryLabel
    }

    var immersiveDescription: String {
        "\(subtitle), snow muffling the street"
    }
}
