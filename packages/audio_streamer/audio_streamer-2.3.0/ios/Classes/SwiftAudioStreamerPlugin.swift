import AVFoundation
import Flutter
import UIKit

public class SwiftAudioStreamerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventSink: FlutterEventSink?
  var engine = AVAudioEngine()
  var audioData: [Float] = []
  var recording = false
  var preferredSampleRate: Int? = nil

  // Register plugin
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAudioStreamerPlugin()

    // Set flutter communication channel for emitting updates
    let eventChannel = FlutterEventChannel.init(
      name: "audio_streamer.eventChannel", binaryMessenger: registrar.messenger())
    // Set flutter communication channel for receiving method calls
    let methodChannel = FlutterMethodChannel.init(
      name: "audio_streamer.methodChannel", binaryMessenger: registrar.messenger())
    methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if call.method == "getSampleRate" {
        // Return sample rate that is currently being used, may differ from requested
        result(Int(AVAudioSession.sharedInstance().sampleRate))
      }
    }
    eventChannel.setStreamHandler(instance)
    instance.setupNotifications()
  }

  private func setupNotifications() {
    // Get the default notification center instance.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption(notification:)),
      name: AVAudioSession.interruptionNotification,
      object: nil)
  }

  @objc func handleInterruption(notification: Notification) {
    // If no eventSink to emit events to, do nothing (wait)
    if eventSink == nil {
      return
    }

    guard let userInfo = notification.userInfo,
      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else {
      return
    }

    switch type {
    case .began: ()
    case .ended:
      // An interruption ended. Resume playback, if appropriate.

      guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
        return
      }
      let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
      if options.contains(.shouldResume) {
        startRecording(sampleRate: preferredSampleRate)
      }

    default:
      eventSink!(
        FlutterError(
          code: "100", message: "Recording was interrupted",
          details: "Another process interrupted recording."))
    }
  }

  // Handle stream emitting (Swift => Flutter)
  private func emitValues(values: [Float]) {

    // If no eventSink to emit events to, do nothing (wait)
    if eventSink == nil {
      return
    }
    // Emit values count event to Flutter
    eventSink!(values)
  }

  // Event Channel: On Stream Listen
  public func onListen(
    withArguments arguments: Any?,
    eventSink: @escaping FlutterEventSink
  ) -> FlutterError? {
    self.eventSink = eventSink
    if let args = arguments as? [String: Any] {
      preferredSampleRate = args["sampleRate"] as? Int
      startRecording(sampleRate: preferredSampleRate)
    } else {
      startRecording(sampleRate: nil)
    }
    return nil
  }

  // Event Channel: On Stream Cancelled
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    engine.stop()
    return nil
  }

  func startRecording(sampleRate: Int?) {
    engine = AVAudioEngine()

    do {
      // 設定音頻會話以禁用 AGC 和其他自動處理
      let audioSession = AVAudioSession.sharedInstance()
      
      // 使用 .record 類別而不是 .playAndRecord，這樣可以獲得更純淨的音頻輸入
      try audioSession.setCategory(
        AVAudioSession.Category.record,
        mode: AVAudioSession.Mode.measurement, // 使用測量模式禁用音頻處理
        options: [.allowBluetoothA2DP, .duckOthers]
      )
      
      // 嘗試禁用 AGC 和其他音頻增強功能（iOS 私有 API，可能無效但值得嘗試）
      try audioSession.setActive(true, options: [])
      
      // 設定優選的無處理輸入
      if audioSession.responds(to: #selector(AVAudioSession.setPreferredInputNumberOfChannels(_:))) {
        try audioSession.setPreferredInputNumberOfChannels(1)
      }

      if let sampleRateNotNull = sampleRate {
        // 設定採樣率
        try audioSession.setPreferredSampleRate(Double(sampleRateNotNull))
      }

      let input = engine.inputNode
      let bus = 0

      // 獲取輸入格式，確保使用原始格式
      let inputFormat = input.inputFormat(forBus: bus)
      print("iOS 音頻輸入格式: \(inputFormat)")
      print("iOS AGC 禁用設定完成")

      // 使用較小的緩衝區大小以提高響應速度
      let bufferSize: AVAudioFrameCount = 1024 // 減小緩衝區以獲得更快的響應
      
      input.installTap(onBus: bus, bufferSize: bufferSize, format: inputFormat) {
        buffer, _ -> Void in
        let samples = buffer.floatChannelData?[0]
        // audio callback, samples in samples[0]...samples[buffer.frameLength-1]
        let arr = Array(UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
        self.emitValues(values: arr)
      }

      try engine.start()
      print("iOS 錄音引擎啟動成功，AGC 已禁用")
    } catch {
      print("iOS 音頻會話設定失敗: \(error)")
      eventSink!(
        FlutterError(
          code: "100", message: "Unable to start audio session", details: error.localizedDescription
        ))
    }
  }
}
