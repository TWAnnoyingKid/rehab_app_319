import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class NativeAudioRecorder {
  static const MethodChannel _methodChannel =
      MethodChannel('native_audio_recorder');

  // 音頻數據流控制器
  final StreamController<Map<String, double>> _audioLevelController =
      StreamController<Map<String, double>>.broadcast();

  // 公開的音頻數據流
  Stream<Map<String, double>> get audioLevelStream =>
      _audioLevelController.stream;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  // 音頻數據歷史
  final List<double> _peakHistory = [];
  final List<double> _averageHistory = [];

  // 獲取音頻歷史數據
  List<double> get peakHistory => List.unmodifiable(_peakHistory);
  List<double> get averageHistory => List.unmodifiable(_averageHistory);

  NativeAudioRecorder() {
    // 監聽來自原生端的音頻數據
    _methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  // 處理來自原生端的調用
  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onAudioLevel':
        final Map<String, dynamic> rawData =
            Map<String, dynamic>.from(call.arguments);
        final Map<String, double> audioData =
            rawData.map((key, value) => MapEntry(key, value.toDouble()));

        // 更新歷史數據
        _peakHistory.add(audioData['normalizedPeak'] ?? 0.0);
        _averageHistory.add(audioData['normalizedAverage'] ?? 0.0);

        // 限制歷史數據長度
        if (_peakHistory.length > 100) {
          _peakHistory.removeAt(0);
        }
        if (_averageHistory.length > 100) {
          _averageHistory.removeAt(0);
        }

        // 發送數據到流
        _audioLevelController.add(audioData);
        break;
    }
  }

  // 開始錄音
  Future<bool> startRecording() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('原生錄音目前僅支援 iOS');
    }

    try {
      final bool result = await _methodChannel.invokeMethod('startRecording');
      _isRecording = result;

      // 清除歷史數據
      _peakHistory.clear();
      _averageHistory.clear();

      print('原生錄音開始: $result');
      return result;
    } catch (e) {
      print('開始原生錄音時發生錯誤: $e');
      return false;
    }
  }

  // 停止錄音
  Future<bool> stopRecording() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('原生錄音目前僅支援 iOS');
    }

    try {
      final bool result = await _methodChannel.invokeMethod('stopRecording');
      _isRecording = false;
      print('原生錄音停止: $result');
      return result;
    } catch (e) {
      print('停止原生錄音時發生錯誤: $e');
      return false;
    }
  }

  // 獲取當前音頻等級
  Future<Map<String, double>?> getCurrentAudioLevel() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('原生錄音目前僅支援 iOS');
    }

    try {
      final Map<String, dynamic> rawResult = Map<String, dynamic>.from(
          await _methodChannel.invokeMethod('getAudioLevel'));
      return rawResult.map((key, value) => MapEntry(key, value.toDouble()));
    } catch (e) {
      print('獲取音頻等級時發生錯誤: $e');
      return null;
    }
  }

  // 獲取最近的峰值數據（用於波形顯示）
  List<double> getRecentPeaks({int count = 50}) {
    if (_peakHistory.length <= count) {
      return List.from(_peakHistory);
    }
    return _peakHistory.sublist(_peakHistory.length - count);
  }

  // 獲取最近的平均值數據
  List<double> getRecentAverages({int count = 50}) {
    if (_averageHistory.length <= count) {
      return List.from(_averageHistory);
    }
    return _averageHistory.sublist(_averageHistory.length - count);
  }

  // 銷毀資源
  void dispose() {
    if (_isRecording) {
      stopRecording();
    }
    _audioLevelController.close();
  }
}
