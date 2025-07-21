import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var audioProcessor: IOSAudioProcessor?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // 註冊原生音訊處理器
    setupAudioProcessor(controller: controller)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupAudioProcessor(controller: FlutterViewController) {
    print("AppDelegate: 設置音訊處理器...")
    
    audioProcessor = IOSAudioProcessor()
    
    let methodChannel = FlutterMethodChannel(name: "ios_audio_processor", binaryMessenger: controller.binaryMessenger)
    let eventChannel = FlutterEventChannel(name: "ios_audio_processor_stream", binaryMessenger: controller.binaryMessenger)
    
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      print("AppDelegate: 接收到方法調用: \(call.method)")
      
      switch call.method {
      case "startAudioProcessing":
        do {
          try self?.audioProcessor?.startAudioProcessing()
          result(nil)
          print("AppDelegate: 音訊處理啟動成功")
        } catch {
          let flutterError = FlutterError(code: "AUDIO_ERROR", message: error.localizedDescription, details: nil)
          result(flutterError)
          print("AppDelegate: 音訊處理啟動失敗: \(error)")
        }
      case "stopAudioProcessing":
        self?.audioProcessor?.stopAudioProcessing()
        result(nil)
        print("AppDelegate: 音訊處理停止完成")
      default:
        result(FlutterMethodNotImplemented)
        print("AppDelegate: 未實現的方法: \(call.method)")
      }
    }
    
    eventChannel.setStreamHandler(audioProcessor)
    print("AppDelegate: 音訊處理器設置完成")
  }
}