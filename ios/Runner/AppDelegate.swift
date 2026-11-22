import Flutter
import UIKit
import GoogleMaps
import Photos
import AVFoundation
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let ringtoneManager = OrderRingtoneManager.shared

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCJpkzNIEmPoiOUTc76RB-AwhCk06GN2JU")
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let imageChannel = FlutterMethodChannel(name: "image_saver", binaryMessenger: controller.binaryMessenger)
      imageChannel.setMethodCallHandler { [weak self] (call, result) in
        if call.method == "saveImage" {
          guard let args = call.arguments as? [String: Any],
                let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_PATH", message: "File path is null", details: nil))
            return
          }
          self?.saveImageToGallery(filePath: filePath, result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      let ringtoneChannel = FlutterMethodChannel(name: "tangzo/order_ringtone", binaryMessenger: controller.binaryMessenger)
      ringtoneChannel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "start":
          let args = call.arguments as? [String: Any]
          let url = args?["url"] as? String
          // Minimum 20s ring (admin remote URL is often ~5s).
          let minSeconds = (args?["minSeconds"] as? Int) ?? 20
          self?.ringtoneManager.start(urlString: url, minSeconds: minSeconds)
          result(nil)
        case "stop":
          self?.ringtoneManager.stop()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Do not override UNUserNotificationCenter / didReceiveRemoteNotification —
    // FlutterFire owns those. Intercepting them breaks background notifications.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveImageToGallery(filePath: String, result: @escaping FlutterResult) {
    let image = UIImage(contentsOfFile: filePath)
    if let image = image {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      result(true)
    } else {
      result(FlutterError(code: "SAVE_FAILED", message: "Failed to save image", details: nil))
    }
  }
}

/// Loops order alert audio (requires UIBackgroundModes → audio).
/// Started only via Flutter method channel so FCM delivery stays intact.
final class OrderRingtoneManager: NSObject, AVAudioPlayerDelegate {
  static let shared = OrderRingtoneManager()

  private var player: AVAudioPlayer?
  private var stopTimer: Timer?
  private var isPlaying = false

  func start(urlString: String?, minSeconds: Int = 20) {
    stopPlayersOnly()
    activateSession()

    // Prefer bundled 20s bell so ring lasts long enough (remote URLs are often short).
    if let bundled = Bundle.main.url(forResource: "order_bell", withExtension: "caf") {
      playLocal(url: bundled, minSeconds: max(20, minSeconds))
      isPlaying = true
      return
    }

    if let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
       !urlString.isEmpty,
       let remoteURL = URL(string: urlString) {
      downloadAndPlay(url: remoteURL, minSeconds: max(20, minSeconds))
      isPlaying = true
      return
    }

    AudioServicesPlaySystemSound(1005)
  }

  func stop() {
    isPlaying = false
    stopPlayersOnly()
  }

  private func activateSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, mode: .default, options: [.duckOthers])
      try session.setActive(true, options: [])
    } catch {
      NSLog("OrderRingtoneManager session error: \(error)")
    }
  }

  private func playLocal(url: URL, minSeconds: Int) {
    do {
      let audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer.numberOfLoops = -1
      audioPlayer.volume = 1.0
      audioPlayer.delegate = self
      audioPlayer.prepareToPlay()
      audioPlayer.play()
      player = audioPlayer
      scheduleAutoStop(after: minSeconds)
    } catch {
      NSLog("OrderRingtoneManager local play error: \(error)")
    }
  }

  private func downloadAndPlay(url: URL, minSeconds: Int) {
    URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      guard let self = self else { return }
      if error != nil {
        DispatchQueue.main.async {
          if let bundled = Bundle.main.url(forResource: "order_bell", withExtension: "caf") {
            self.playLocal(url: bundled, minSeconds: minSeconds)
          }
        }
        return
      }
      guard let data = data, !data.isEmpty else { return }
      DispatchQueue.main.async {
        do {
          let audioPlayer = try AVAudioPlayer(data: data)
          audioPlayer.numberOfLoops = -1
          audioPlayer.volume = 1.0
          audioPlayer.delegate = self
          audioPlayer.prepareToPlay()
          audioPlayer.play()
          self.player = audioPlayer
          self.scheduleAutoStop(after: minSeconds)
        } catch {
          if let bundled = Bundle.main.url(forResource: "order_bell", withExtension: "caf") {
            self.playLocal(url: bundled, minSeconds: minSeconds)
          }
        }
      }
    }.resume()
  }

  private func scheduleAutoStop(after seconds: Int) {
    stopTimer?.invalidate()
    // Keep ringing until Flutter stops; long safety net only.
    let safety = max(seconds, 300)
    stopTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(safety), repeats: false) { [weak self] _ in
      self?.stop()
    }
  }

  private func stopPlayersOnly() {
    stopTimer?.invalidate()
    stopTimer = nil
    player?.stop()
    player = nil
  }
}
