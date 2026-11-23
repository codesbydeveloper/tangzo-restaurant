import Flutter
import UIKit
import GoogleMaps
import Photos
import AVFoundation
import AudioToolbox
import UserNotifications

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
          // Ignore remote admin URL — it is often ~5s. Always use bundled 20s bell.
          let args = call.arguments as? [String: Any]
          let minSeconds = (args?["minSeconds"] as? Int) ?? 20
          self?.ringtoneManager.start(minSeconds: minSeconds)
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

  /// content-available wake. Start 20s bell and delay fetch completion so iOS
  /// does not suspend the app after ~5s (which was cutting the ring short).
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    let shouldRing = Self.isOrderAlert(userInfo)
    if shouldRing {
      ringtoneManager.start(minSeconds: 20)
    }

    // Forward to FlutterFire, but wrap completion so audio can finish (≥20s).
    var completed = false
    let finish: (UIBackgroundFetchResult) -> Void = { result in
      let delay: TimeInterval = shouldRing ? 22 : 0
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        guard !completed else { return }
        completed = true
        completionHandler(result)
      }
    }

    super.application(
      application,
      didReceiveRemoteNotification: userInfo,
      fetchCompletionHandler: finish
    )
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

  static func isOrderAlert(_ userInfo: [AnyHashable: Any]) -> Bool {
    let play = "\(userInfo["play_ringtone"] ?? "")".lowercased()
    if play == "true" || play == "1" { return true }
    let type = "\(userInfo["type"] ?? "")".lowercased()
    return type.contains("order_placed")
      || type.contains("new_order")
      || type.contains("schedule_order")
      || type.contains("dinein_placed")
      || type.contains("new_delivery_order")
  }
}

@available(iOS 10.0, *)
extension AppDelegate {
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if Self.isOrderAlert(notification.request.content.userInfo) {
      ringtoneManager.start(minSeconds: 20)
    }
    super.userNotificationCenter(
      center,
      willPresent: notification,
      withCompletionHandler: completionHandler
    )
  }
}

/// Plays bundled order_bell.caf for at least 20 seconds (loops if needed).
final class OrderRingtoneManager: NSObject, AVAudioPlayerDelegate {
  static let shared = OrderRingtoneManager()

  private var player: AVAudioPlayer?
  private var stopTimer: Timer?
  private var bgTask = UIBackgroundTaskIdentifier.invalid
  private var isPlaying = false
  private var startedAt: Date?

  func start(minSeconds: Int = 20) {
    let seconds = max(20, minSeconds)
    stopPlayersOnly()
    activateSession()
    beginBgTask()
    startedAt = Date()
    isPlaying = true

    guard let bundled = Bundle.main.url(forResource: "order_bell", withExtension: "caf") else {
      NSLog("OrderRingtoneManager: order_bell.caf missing from bundle")
      AudioServicesPlaySystemSound(1005)
      endBgTask()
      isPlaying = false
      return
    }
    playLocal(url: bundled, minSeconds: seconds)
  }

  func stop() {
    // Enforce minimum ring time so a quick Flutter stop / stream flicker
    // cannot cut a background ring to ~5s.
    if let startedAt, isPlaying {
      let elapsed = Date().timeIntervalSince(startedAt)
      if elapsed < 20 {
        let remaining = 20 - elapsed
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
          self?.forceStop()
        }
        return
      }
    }
    forceStop()
  }

  private func forceStop() {
    isPlaying = false
    startedAt = nil
    stopPlayersOnly()
    endBgTask()
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
      // Loop so short files (or one 20s pass) cover the full min window.
      let duration = max(audioPlayer.duration, 1)
      let loopsNeeded = Int(ceil(Double(minSeconds) / duration)) - 1
      audioPlayer.numberOfLoops = max(loopsNeeded, 0)
      audioPlayer.volume = 1.0
      audioPlayer.delegate = self
      audioPlayer.prepareToPlay()
      let ok = audioPlayer.play()
      NSLog("OrderRingtoneManager play ok=\(ok) duration=\(duration) loops=\(audioPlayer.numberOfLoops) min=\(minSeconds)")
      player = audioPlayer
      scheduleAutoStop(after: minSeconds)
    } catch {
      NSLog("OrderRingtoneManager local play error: \(error)")
      forceStop()
    }
  }

  private func scheduleAutoStop(after seconds: Int) {
    stopTimer?.invalidate()
    let timer = Timer(timeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
      self?.forceStop()
    }
    RunLoop.main.add(timer, forMode: .common)
    stopTimer = timer
  }

  private func stopPlayersOnly() {
    stopTimer?.invalidate()
    stopTimer = nil
    player?.stop()
    player = nil
  }

  private func beginBgTask() {
    if bgTask != .invalid {
      UIApplication.shared.endBackgroundTask(bgTask)
      bgTask = .invalid
    }
    bgTask = UIApplication.shared.beginBackgroundTask(withName: "order_ringtone") { [weak self] in
      self?.forceStop()
    }
  }

  private func endBgTask() {
    guard bgTask != .invalid else { return }
    UIApplication.shared.endBackgroundTask(bgTask)
    bgTask = .invalid
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if isPlaying {
      player.play()
    }
  }
}
