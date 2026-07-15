import AVFoundation
import Foundation

@MainActor
final class CandidateAudioPlayer {
    static let shared = CandidateAudioPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    func play(url: URL?) {
        stop()
        guard let url else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
        } catch {
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
