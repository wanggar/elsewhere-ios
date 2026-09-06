import AVFoundation
import Combine
import Foundation

/// Plays the pre-sign-in sample sounds. All samples are bundled, preloaded, and looped;
/// switching between samples crossfades instead of cutting.
@MainActor
final class SampleAudioPlayer: ObservableObject {
    @Published private(set) var playingID: UUID?

    private var players: [UUID: AVQueuePlayer] = [:]
    private var loopers: [UUID: AVPlayerLooper] = [:]
    private var fadeTask: Task<Void, Never>?

    func preload(_ sources: [(id: UUID, url: URL)]) {
        for source in sources where players[source.id] == nil {
            let item = AVPlayerItem(url: source.url)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            queuePlayer.volume = 0
            loopers[source.id] = AVPlayerLooper(player: queuePlayer, templateItem: item)
            players[source.id] = queuePlayer
        }
    }

    func play(id: UUID) {
        guard let player = players[id] else { return }
        fadeTask?.cancel()
        let previousID = playingID
        playingID = id

        fadeTask = Task {
            if let previousID, previousID != id, let previous = players[previousID] {
                await fade(previous, to: 0, duration: 0.35)
                guard !Task.isCancelled else { return }
                previous.pause()
            }
            activateSession()
            guard !Task.isCancelled else { return }
            player.play()
            await fade(player, to: 1, duration: 0.9)
        }
    }

    func pause() {
        fadeTask?.cancel()
        guard let id = playingID, let player = players[id] else {
            playingID = nil
            return
        }
        playingID = nil
        fadeTask = Task {
            await fade(player, to: 0, duration: 0.35)
            guard !Task.isCancelled else { return }
            player.pause()
            deactivateSession()
        }
    }

    func stop() {
        fadeTask?.cancel()
        players.values.forEach { $0.pause() }
        playingID = nil
        deactivateSession()
    }

    private func fade(_ player: AVQueuePlayer, to target: Float, duration: Double) async {
        let steps = 24
        let start = player.volume
        for step in 1...steps {
            try? await Task.sleep(for: .milliseconds(Int(duration * 1000) / steps))
            guard !Task.isCancelled else { return }
            player.volume = start + (target - start) * Float(step) / Float(steps)
        }
    }

    private func activateSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
