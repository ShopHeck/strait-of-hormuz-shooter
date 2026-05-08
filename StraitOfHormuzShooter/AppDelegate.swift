import UIKit
import AVFoundation

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool { true }
}

final class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    var muted: Bool { get { UserDefaults.standard.bool(forKey: "muted") } set { UserDefaults.standard.set(newValue, forKey: "muted") } }
    func playSFX(_ name: String) { guard !muted, let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }; player = try? AVAudioPlayer(contentsOf: url); player?.play() }
}
