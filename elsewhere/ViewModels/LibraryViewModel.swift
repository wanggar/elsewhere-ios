import Foundation
import Observation

@Observable
final class LibraryViewModel {
    var library: SoundLibrary

    init(library: SoundLibrary = .initial) {
        self.library = library
    }

    func add(_ sound: SavedSound) {
        library.add(sound)
    }

    func delete(_ sound: SavedSound) {
        library.delete(sound)
    }

    func deleteLast(in mode: CuratorMode) {
        let sounds = library.sounds(for: mode)
        if let last = sounds.last {
            library.delete(last)
        }
    }
}
