import Foundation

/// Local file cache for generated audio. Audio is now authoritative in Supabase Storage;
/// this store is only used for temporary preview files during the generation flow.
enum SoundFileStore {
    static var soundsDirectory: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Sounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    /// Cleans up all locally cached MP3 files. Call on sign-out if desired.
    static func clearAll() {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: soundsDirectory, includingPropertiesForKeys: nil
        ) else { return }
        for url in contents {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
