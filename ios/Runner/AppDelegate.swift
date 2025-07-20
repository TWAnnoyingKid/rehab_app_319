import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var audioStreamHandler: AudioStreamHandler?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        // 設置 MethodChannel
        let methodChannel = FlutterMethodChannel(name: "com.rehab_app.audio/method",
                                                 binaryMessenger: controller.binaryMessenger)
        
        // 設置 EventChannel
        let eventChannel = FlutterEventChannel(name: "com.rehab_app.audio/event",
                                               binaryMessenger: controller.binaryMessenger)
        
        // 實例化我們的音訊處理器
        self.audioStreamHandler = AudioStreamHandler()
        
        // 將 EventChannel 的處理器設定為我們的 audioStreamHandler
        eventChannel.setStreamHandler(self.audioStreamHandler)
        
        // 設定 MethodChannel 的呼叫處理
        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            guard let self = self else { return }
            
            switch call.method {
            case "start":
                self.audioStreamHandler?.start()
                result(nil) // 回應 Flutter 表示成功
            case "stop":
                self.audioStreamHandler?.stop()
                result(nil) // 回應 Flutter 表示成功
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}