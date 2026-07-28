import AVFoundation
import Foundation

@MainActor
final class CandidateAudioPlayer {
    static let shared = CandidateAudioPlayer()

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    private init() {}

    func play(url: URL?) {
        stop()
        guard let url else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }

        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(items: [item])
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        player?.play()
    }

    func stop() {
        player?.pause()
        looper = nil
        player = nil
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
