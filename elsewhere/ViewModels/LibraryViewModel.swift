import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    var library: SoundLibrary
    private(set) var isFetching = false
    private(set) var fetchError: String?

    init(library: SoundLibrary = .initial) {
        self.library = library
    }

    // MARK: - Fetch from API

    func fetchLibrary() async {
        isFetching = true
        fetchError = nil
        do {
            let data = try await APIClient.request(url: APIConfig.libraryURL)
            let response = try JSONDecoder().decode(LibraryResponse.self, from: data)
            let sounds = response.sounds.map { dto in
                SavedSound(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    title: dto.title,
                    subtitle: dto.subtitle,
                    mode: CuratorMode(rawValue: dto.mode) ?? .sleep,
                    audioURL: URL(string: dto.audioUrl)
                )
            }
            library = SoundLibrary(sounds: sounds, activeMode: sounds.first?.mode ?? .sleep)
        } catch {
            fetchError = error.localizedDescription
        }
        isFetching = false
    }

    // MARK: - Mutations

    /// Called after a successful POST /api/library — adds the sound locally.
    func add(_ sound: SavedSound) {
        library.add(sound)
    }

    /// Soft-deletes on the server, then removes locally on success.
    func delete(_ sound: SavedSound) {
        Task {
            do {
                let url = APIConfig.libraryItemURL(id: sound.id.uuidString)
                _ = try await APIClient.request(url: url, method: "DELETE")
                ConversationMemoryStore.delete(for: sound.id)
                library.delete(sound)
            } catch {
                fetchError = "Couldn't delete — try again."
                print("[LibraryViewModel] delete error:", error.localizedDescription)
            }
        }
    }

    func deleteLast(in mode: CuratorMode) {
        let sounds = library.sounds(for: mode)
        if let last = sounds.last {
            delete(last)
        }
    }

    // MARK: - Decodable response type

    private struct LibraryResponse: Decodable {
        let sounds: [SoundDTO]
    }

    private struct SoundDTO: Decodable {
        let id: String
        let mode: String
        let title: String
        let subtitle: String
        let audioUrl: String
        let createdAt: String
    }
}
