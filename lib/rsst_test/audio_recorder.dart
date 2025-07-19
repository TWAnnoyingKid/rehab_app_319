import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  final Record _recorder = Record();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _recordingPath;
  final int _sampleRate = 44100;
  Completer<void>? _initCompleter;

  // 建構函數
  AudioRecorder();

  // 獲取錄音路徑
  String? get recordingPath => _recordingPath;

  // 初始化錄音機
  Future<void> init() async {
    // 如果已經在初始化中，返回相同的 Future
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      if (_isRecorderInitialized) {
        _initCompleter!.complete();
        return _initCompleter!.future;
      }

      print('初始化錄音器...');

      // iOS 特殊處理：添加延遲確保權限狀態穩定
      if (Platform.isIOS) {
        print('iOS 平台：準備音頻會話...');
        await Future.delayed(Duration(milliseconds: 500));
      }

      // 請求錄音權限
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('麥克風權限未授予，當前狀態: $status');
      }
      print('麥克風權限已授予');

      // iOS 特殊處理：再次確認權限並等待
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 300));
        var doubleCheckStatus = await Permission.microphone.status;
        if (!doubleCheckStatus.isGranted) {
          throw RecordingPermissionException('iOS 權限狀態不穩定，狀態: $doubleCheckStatus');
        }
        print('iOS 權限狀態確認完成');
      }

      // 檢查是否可以錄音
      bool canRecord = await _recorder.hasPermission();
      if (!canRecord) {
        // iOS 特殊處理：嘗試再次檢查
        if (Platform.isIOS) {
          print('iOS 第一次權限檢查失敗，嘗試重新檢查...');
          await Future.delayed(Duration(milliseconds: 500));
          canRecord = await _recorder.hasPermission();
          if (!canRecord) {
            throw RecordingPermissionException('iOS 無法獲得錄音權限，請檢查設定中的麥克風權限');
          }
        } else {
          throw RecordingPermissionException('無法獲得錄音權限');
        }
      }

      _isRecorderInitialized = true;
      print('錄音機初始化完成');
      _initCompleter!.complete();
    } catch (e) {
      print('初始化錄音機失敗: $e');
      _initCompleter!.completeError(e);
    }

    return _initCompleter!.future;
  }

  // 開始錄音
  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      await init();
    }

    // 確保錄音機已初始化
    if (!_isRecorderInitialized) {
      throw RecordingPermissionException('錄音機未初始化');
    }

    // 如果已經在錄音，先停止
    if (_isRecording) {
      await stopRecording();
    }

    // 創建檔案路徑
    final directory = await getApplicationDocumentsDirectory();
    _recordingPath = '${directory.path}/rsst_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    print('檔案將保存至: $_recordingPath');

    try {
      // iOS 特殊處理：在開始錄音前添加延遲
      if (Platform.isIOS) {
        print('iOS 平台：準備開始錄音...');
        await Future.delayed(Duration(milliseconds: 200));
      }

      // 再次檢查麥克風權限
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        throw RecordingPermissionException('麥克風權限未授予或已被撤銷，狀態: $status');
      }

      // 確保目錄存在
      final dir = Directory(directory.path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // iOS 特殊處理：使用更保守的錄音配置
      if (Platform.isIOS) {
        print('iOS 平台：使用優化的錄音設定...');
        
        // 開始錄音 - iOS 優化設定
        await _recorder.start(
          path: _recordingPath,
          encoder: AudioEncoder.wav,      // WAV格式
          bitRate: 32000,                 // 32 kbps (更保守的設定)
          samplingRate: 16000,            // 16 kHz (iOS 更相容)
          numChannels: 1,                 // 單聲道
        );
      } else {
        // Android 使用原始設定
        await _recorder.start(
          path: _recordingPath,
          encoder: AudioEncoder.wav,      // WAV格式
          bitRate: 16 * 1000,             // 16 kbps
          samplingRate: _sampleRate,      // 44.1 kHz
          numChannels: 1,                 // 單聲道
        );
      }

      // 設置音量監聽器
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 300)).listen((amp) {
        print('錄音中，音量: ${amp.current} dB, 峰值: ${amp.max} dB');
      });

      print('錄音開始成功 (${Platform.isIOS ? "iOS" : "Android"} 模式)');
      _isRecording = true;
    } catch (e) {
      print('開始錄音失敗: $e');
      if (Platform.isIOS) {
        throw Exception('iOS 錄音失敗: $e\n請確認在設定中已授予麥克風權限');
      } else {
        throw Exception('開始錄音失敗: $e');
      }
    }
  }

  // 停止錄音
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return _recordingPath;
    }

    try {
      print('正在停止錄音...');
      await _recorder.stop();
      _isRecording = false;

      // 驗證錄音檔案
      if (_recordingPath != null) {
        File audioFile = File(_recordingPath!);
        if (await audioFile.exists()) {
          int fileSize = await audioFile.length();
          print('錄音完成，檔案大小: ${fileSize} 位元組');

          // 檢查檔案大小是否異常（小於1KB可能表示錄音失敗）
          if (fileSize < 1024) {
            print('警告：錄音檔案大小異常小，可能錄音失敗');
            if (fileSize < 100) {
              print('嚴重錯誤：錄音檔案實際上為空');
              return null;
            }
          }
        } else {
          print('錄音檔案不存在: $_recordingPath');
          return null;
        }
      }

      print('錄音完成，檔案儲存於: $_recordingPath');
      return _recordingPath;
    } catch (e) {
      print('停止錄音出錯: $e');
      _isRecording = false;
      return _recordingPath;
    }
  }

  // 釋放資源
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }

      if (_isRecorderInitialized) {
        _recorder.dispose();
        _isRecorderInitialized = false;
        print('錄音機資源已釋放');
      }
    } catch (e) {
      print('釋放錄音機資源時出錯: $e');
    }
  }
}

// 自定義例外
class RecordingPermissionException implements Exception {
  final String message;
  RecordingPermissionException(this.message);

  @override
  String toString() => 'RecordingPermissionException: $message';
}