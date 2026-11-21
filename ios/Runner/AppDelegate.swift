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
          self?.ringtoneManager.start(urlString: url)
          result(nil)
        case "stop":
          self?.ringtoneManager.stop()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

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

/// Loops order alert audio in foreground/background (requires UIBackgroundModes audio).
final class OrderRingtoneManager: NSObject, AVAudioPlayerDelegate {
  static let shared = OrderRingtoneManager()

  private var player: AVAudioPlayer?
  private var remotePlayer: AVPlayer?
  private var remoteEndObserver: NSObjectProtocol?
  private var isPlaying = false

  func start(urlString: String?) {
    stopPlayersOnly()
    activateSession()

    // Prefer remote URL (admin-configured ringtone), fall back to bundled order_bell.caf.
    if let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
       !urlString.isEmpty,
       let remoteURL = URL(string: urlString) {
      playRemote(url: remoteURL)
      isPlaying = true
      return
    }

    if let bundled = Bundle.main.url(forResource: "order_bell", withExtension: "caf") {
      playLocal(url: bundled)
      isPlaying = true
      return
    }

    // Last resort: system alert sound so something still plays.
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

  private func playLocal(url: URL) {
    do {
      let audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer.numberOfLoops = -1
      audioPlayer.volume = 1.0
      audioPlayer.delegate = self
      audioPlayer.prepareToPlay()
      audioPlayer.play()
      player = audioPlayer
    } catch {
      NSLog("OrderRingtoneManager local play error: \(error)")
    }
  }

  private func playRemote(url: URL) {
    let item = AVPlayerItem(url: url)
    let avPlayer = AVPlayer(playerItem: item)
    avPlayer.actionAtItemEnd = .none
    remoteEndObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak avPlayer] _ in
      avPlayer?.seek(to: .zero)
      avPlayer?.play()
    }
    avPlayer.play()
    remotePlayer = avPlayer
  }

  private func stopPlayersOnly() {
    player?.stop()
    player = nil
    remotePlayer?.pause()
    remotePlayer = nil
    if let observer = remoteEndObserver {
      NotificationCenter.default.removeObserver(observer)
      remoteEndObserver = nil
    }
  }
}
