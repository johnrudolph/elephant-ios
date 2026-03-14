import AVFoundation

@Observable
final class AudioManager {
    static let shared = AudioManager()

    var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "gameAudioMuted")
        }
    }

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        self.isMuted = UserDefaults.standard.bool(forKey: "gameAudioMuted")
    }

    func playSlide() {
        play("slide_\(Int.random(in: 1...5))")
    }

    func playElephant() {
        play("elephant_\(Int.random(in: 1...2))")
    }

    func playVictory() {
        play("victory")
    }

    func playDefeat() {
        play("defeat")
    }

    private func play(_ name: String) {
        guard !isMuted else { return }

        // Try to find the audio file in the bundle
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            // Audio file not found — placeholder; will work once files are added
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[name] = player // retain reference
            player.play()
        } catch {
            // Silently fail — audio is non-critical
        }
    }
}
