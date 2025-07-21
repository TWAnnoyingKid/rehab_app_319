import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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

      // 請求錄音權限
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('麥克風權限未授予');
      }
      print('麥克風權限已授予');

      // 檢查是否可以錄音
      bool canRecord = await _recorder.hasPermission();
      if (!canRecord) {
        throw RecordingPermissionException('無法獲得錄音權限');
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
      // 再次檢查麥克風權限
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        throw RecordingPermissionException('麥克風權限未授予或已被撤銷');
      }

      // 確保目錄存在
      final dir = Directory(directory.path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 開始錄音
      await _recorder.start(
        path: _recordingPath,
        encoder: AudioEncoder.wav,  // WAV格式
        bitRate: 16 * 1000,         // 16 kbps
        samplingRate: _sampleRate,  // 44.1 kHz
        numChannels: 1,             // 單聲道
      );

      // 設置音量監聽器
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 300)).listen((amp) {
        print('錄音中，音量: ${amp.current} dB, 峰值: ${amp.max} dB');
      });

      print('錄音開始');
      _isRecording = true;
    } catch (e) {
      print('開始錄音失敗: $e');
      throw Exception('開始錄音失敗: $e');
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