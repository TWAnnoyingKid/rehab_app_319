import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioLevelTimer: Timer?
    private var methodChannel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // 設置原生音頻錄音 MethodChannel
        let controller = window?.rootViewController as! FlutterViewController
        methodChannel = FlutterMethodChannel(name: "native_audio_recorder", binaryMessenger: controller.binaryMessenger)
        
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "startRecording":
                self?.startNativeRecording(result: result)
            case "stopRecording":
                self?.stopNativeRecording(result: result)
            case "getAudioLevel":
                self?.getAudioLevel(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func startNativeRecording(result: @escaping FlutterResult) {
        // 設置音頻會話
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true)
            
            // 配置錄音設置 - 使用未處理的原始設定
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            // 創建錄音器
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("temp_recording.wav")
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true // 啟用音量測量
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            // 啟動高頻率音量監測定時器（20ms 更新一次）
            audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
            
            result(true)
        } catch {
            result(FlutterError(code: "RECORDING_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func stopNativeRecording(result: @escaping FlutterResult) {
        audioRecorder?.stop()
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
        
        result(true)
    }
    
    private func getAudioLevel(result: @escaping FlutterResult) {
        guard let recorder = audioRecorder, recorder.isRecording else {
            result(0.0)
            return
        }
        
        recorder.updateMeters()
        
        // 獲取原始的音量數據（未平滑處理）
        let averagePower = recorder.averagePower(forChannel: 0) // 平均功率
        let peakPower = recorder.peakPower(forChannel: 0)       // 峰值功率
        
        // 轉換為 0-1 的線性值（未經平滑處理）
        let normalizedAverage = pow(10, averagePower / 20)
        let normalizedPeak = pow(10, peakPower / 20)
        
        // 返回包含多種數據的字典
        let audioData: [String: Double] = [
            "averagePower": Double(averagePower),
            "peakPower": Double(peakPower),
            "normalizedAverage": Double(normalizedAverage),
            "normalizedPeak": Double(normalizedPeak),
            "rawAmplitude": Double(normalizedPeak) // 使用峰值作為原始振幅
        ]
        
        result(audioData)
    }
    
    private func updateAudioLevel() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        let peakPower = recorder.peakPower(forChannel: 0)
        let normalizedPeak = pow(10, peakPower / 20)
        
        // 發送即時音頻數據到 Flutter
        let audioData: [String: Double] = [
            "averagePower": Double(averagePower),
            "peakPower": Double(peakPower),
            "normalizedPeak": Double(normalizedPeak),
            "timestamp": Date().timeIntervalSince1970 * 1000 // 毫秒時間戳
        ]
        
        methodChannel?.invokeMethod("onAudioLevel", arguments: audioData)
    }
}
