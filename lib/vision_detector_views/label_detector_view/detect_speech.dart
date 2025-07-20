import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../trainmouth/trainmouth_widget.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // 添加這個 import 來檢測平台

/// **第一個畫面：讓使用者選擇 PA、TA、KA**
class speech extends StatefulWidget {
  const speech({super.key});

  @override
  State<speech> createState() => _speechState();
}

class _speechState extends State<speech> {
  // 用於追蹤已完成的音素測試
  final Map<String, int> completedPhonemes = {"PA": 0, "TA": 0, "KA": 0};

  void _navigateToDetectionScreen(BuildContext context, String phoneme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoundDetectionScreen(
          selectedPhoneme: phoneme,
          onComplete: (wordCount) {
            // 測試完成後更新狀態
            setState(() {
              completedPhonemes[phoneme] = wordCount;
            });
          },
        ),
      ),
    );
  }

  // 檢查是否已完成所有測試
  bool _allTestsCompleted() {
    return completedPhonemes.values.every((count) => count > 0);
  }

  // 上傳結果並顯示對話框
  void _uploadResults(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _UploadDialog(completedPhonemes: completedPhonemes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: const Text(
          "發音練習",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87), // 確保返回按鈕是黑色的
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), // 調整底部間距
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "請依序完成以下三個音節測試。\n每個測試持續10秒，請盡可能多次且清晰地發出指定音節。",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 使用 ListView 來放置按鈕，使其更具擴展性
            ListView(
              shrinkWrap: true, // 讓 ListView 只佔用所需空間
              physics: const NeverScrollableScrollPhysics(), // 在此佈局中不需要滾動
              children: [
                _buildPhonemeButton(context, "PA"),
                const SizedBox(height: 15),
                _buildPhonemeButton(context, "TA"),
                const SizedBox(height: 15),
                _buildPhonemeButton(context, "KA"),
              ],
            ),
            const Spacer(), // 使用 Spacer 將按鈕推至底部
            // 顯示已完成的測試
            if (!_allTestsCompleted())
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  "已完成：${completedPhonemes.entries.where((e) => e.value > 0).map((e) => e.key).join('、')}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _allTestsCompleted() ? () => _uploadResults(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _allTestsCompleted() ? "查看並上傳結果" : "完成所有測試以上傳",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        _allTestsCompleted() ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 新的卡片式按鈕設計
  Widget _buildPhonemeButton(BuildContext context, String phoneme) {
    final bool isCompleted = completedPhonemes[phoneme]! > 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => _navigateToDetectionScreen(context, phoneme),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Row(
            children: [
              // 左側圓形標示
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    phoneme,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 中間的文字說明
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "音節 ${phoneme} 測試",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isCompleted ? "已完成" : "點擊開始測試",
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            isCompleted ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 右側的圖示
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 28,
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 上傳對話框元件
class _UploadDialog extends StatefulWidget {
  final Map<String, int> completedPhonemes;

  const _UploadDialog({required this.completedPhonemes});

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  bool isUploading = true;
  bool uploadSuccess = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _performUpload();
  }

  Future<void> _performUpload() async {
    try {
      await endout9(completedPhonemes: widget.completedPhonemes);
      setState(() {
        isUploading = false;
        uploadSuccess = true;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
        uploadSuccess = false;
        errorMessage = '上傳失敗，請檢查您的網路連線';
      });
      print("Error uploading results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading) ...[
              const Text(
                "測試完成！",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 15),
              Text(
                'PA: ${widget.completedPhonemes["PA"]} / TA: ${widget.completedPhonemes["TA"]} / KA: ${widget.completedPhonemes["KA"]}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A90E2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                "正在上傳結果，請稍候...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ] else if (uploadSuccess) ...[
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2ECC71),
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                "上傳成功！",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 15),
              Text(
                'PA: ${widget.completedPhonemes["PA"]} / TA: ${widget.completedPhonemes["TA"]} / KA: ${widget.completedPhonemes["KA"]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A90E2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 關閉對話框
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // // 返回到根頁面，然後導航到 TrainmouthWidget
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrainmouthWidget()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "返回",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                "上傳失敗",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 15),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isUploading = true;
                        uploadSuccess = false;
                        errorMessage = '';
                      });
                      _performUpload();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "重試",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // 關閉對話框
                      // 返回到根頁面，然後導航到 TrainmouthWidget
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TrainmouthWidget()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A90E2)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "返回",
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// **第二個畫面：偵測聲音**
class SoundDetectionScreen extends StatefulWidget {
  final String selectedPhoneme;
  final Function(int) onComplete; // 新增回調函數，用於報告完成狀態

  const SoundDetectionScreen({
    super.key,
    required this.selectedPhoneme,
    required this.onComplete,
  });

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen>
    with SingleTickerProviderStateMixin {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool _isListening = false;
  double _soundLevel = 0.0;
  int _wordCount = 0;
  bool _hasAddedWord = false;

  // 平台特定的音量閾值
  double _dBThreshold = Platform.isIOS ? 75.0 : 80.0; // iOS 通常需要較低的閾值

  // 智慧音節偵測相關變數
  List<double> _recentSoundLevels = []; // 記錄最近的音量
  double _baselineVolume = 30.0; // 基線音量
  int _silentSamples = 0; // 連續靜音樣本數
  DateTime? _lastDetectionTime; // 最後偵測時間
  final int _minSilenceGap = Platform.isIOS ? 8 : 5; // iOS 需要更多靜音樣本才算分隔
  final Duration _minDetectionInterval =
      Duration(milliseconds: Platform.isIOS ? 200 : 150); // iOS 需要更長間隔

  // iOS 特殊調整參數
  double _iosVolumeChangeThreshold = 10.0; // iOS 音量變化閾值 (可調整)

  // 動畫控制
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 倒數計時
  Timer? _countdownTimer;
  int _remainingTime = 10; // 設定倒數 10 秒

  @override
  void initState() {
    super.initState();
    _initializePlatformSpecificSettings(); // 添加平台特定初始化
    _requestPermissions();

    /// 請求麥克風權限

    // 動畫：讓氣泡變大縮小
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 動畫時間 500ms
      lowerBound: 1.0,
      upperBound: 2, // 放大 2 倍
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController);

    ///開始後大小
  }

  // 添加平台特定設置初始化
  void _initializePlatformSpecificSettings() {
    if (Platform.isIOS) {
      print('iOS 平台：使用智慧音節偵測算法');
      // iOS 需要更大的音量歷史緩衝區
      _recentSoundLevels = List.filled(15, 30.0);
    } else {
      print('Android 平台：使用標準音節偵測算法');
      _recentSoundLevels = List.filled(8, 30.0);
    }
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }

    // iOS 特殊處理：確保權限狀態穩定
    if (Platform.isIOS && status.isGranted) {
      await Future.delayed(const Duration(milliseconds: 300));
      print('iOS 權限確認完成');
    }
  }

  void _startListening() {
    if (_isListening) return;

    _resetValues(); // 重置計數與變數
    _noiseMeter ??= NoiseMeter();

    try {
      // 開始監聽音量
      _noiseSubscription = _noiseMeter!.noiseStream.listen((noiseEvent) {
        setState(() {
          _soundLevel = noiseEvent.meanDecibel; //更新音量數據

          // 使用智慧偵測算法
          _processSoundLevel(_soundLevel);
        });
      }, onError: (e) {
        debugPrint('噪音偵測錯誤 (${Platform.isIOS ? "iOS" : "Android"}): $e');
        _stopListening();
      });

      // 開始倒數計時
      _startCountdown();
    } catch (e) {
      debugPrint('啟動偵測時發生錯誤 (${Platform.isIOS ? "iOS" : "Android"}): $e');
      _stopListening();
    }

    setState(() => _isListening = true);
    print(
        '開始音量偵測 - 平台: ${Platform.isIOS ? "iOS" : "Android"}, 閾值: $_dBThreshold dB');
  }

  // 智慧音節偵測核心算法
  void _processSoundLevel(double currentLevel) {
    // 更新音量歷史
    _recentSoundLevels.removeAt(0);
    _recentSoundLevels.add(currentLevel);

    // 更新基線音量（動態調整）
    double avgLevel =
        _recentSoundLevels.reduce((a, b) => a + b) / _recentSoundLevels.length;
    _baselineVolume = _baselineVolume * 0.95 + avgLevel * 0.05;

    bool isSpeaking = currentLevel > _dBThreshold;
    bool wasSilent = _silentSamples > 0;

    if (isSpeaking) {
      _silentSamples = 0;

      // 檢查是否應該計數新音節
      if (_shouldCountNewSyllable()) {
        _countNewSyllable(currentLevel);
      }

      // 觸發視覺回饋
      if (!_animationController.isAnimating ||
          _animationController.value < 0.5) {
        _animationController.forward();
      }
    } else {
      _silentSamples++;

      // 如果靜音足夠長，重置偵測狀態
      if (_silentSamples > _minSilenceGap && _animationController.value > 0.5) {
        _animationController.reverse();
      }
    }
  }

  // 判斷是否應該計數新音節
  bool _shouldCountNewSyllable() {
    DateTime now = DateTime.now();

    // 檢查最小時間間隔
    if (_lastDetectionTime != null) {
      Duration timeSinceLastDetection = now.difference(_lastDetectionTime!);
      if (timeSinceLastDetection < _minDetectionInterval) {
        return false;
      }
    }

    // 檢查是否有足夠的靜音分隔
    bool hadSufficientSilence =
        _silentSamples >= _minSilenceGap || _lastDetectionTime == null;

    // iOS 特殊邏輯：使用音量變化率作為額外判斷
    if (Platform.isIOS && _recentSoundLevels.length >= 5) {
      double recentIncrease = _calculateVolumeIncrease();
      bool hasSignificantIncrease = recentIncrease > _iosVolumeChangeThreshold;
      return hadSufficientSilence && hasSignificantIncrease;
    }

    return hadSufficientSilence;
  }

  // 計算最近的音量增幅 (iOS 專用)
  double _calculateVolumeIncrease() {
    if (_recentSoundLevels.length < 5) return 0.0;

    // 比較最近 3 個樣本與之前 3 個樣本的平均值
    List<double> recent =
        _recentSoundLevels.sublist(_recentSoundLevels.length - 3);
    List<double> previous = _recentSoundLevels.sublist(
        _recentSoundLevels.length - 6, _recentSoundLevels.length - 3);

    double recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    double previousAvg = previous.reduce((a, b) => a + b) / previous.length;

    return recentAvg - previousAvg;
  }

  // 計數新音節
  void _countNewSyllable(double currentLevel) {
    _wordCount++;
    _lastDetectionTime = DateTime.now();
    _silentSamples = 0; // 重置靜音計數

    print(
        '${Platform.isIOS ? "iOS" : "Android"} 偵測到音節 #$_wordCount，音量: ${currentLevel.toStringAsFixed(1)} dB');

    // 觸發動畫
    _animationController.forward();
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
    _countdownTimer?.cancel(); // 停止倒數
    setState(() {
      _isListening = false;
      _animationController.reverse(); // 測試停止時，氣泡恢復原狀
    });
  }

  void _resetValues() {
    setState(() {
      _wordCount = 0;
      _soundLevel = 0.0;
      _hasAddedWord = false;
      _remainingTime = 10; // 重置倒數

      // 重置智慧偵測變數
      _silentSamples = 0;
      _lastDetectionTime = null;
      _baselineVolume = 30.0;
      if (Platform.isIOS) {
        _recentSoundLevels = List.filled(15, 30.0);
        // 保持用戶調整的iOS閾值設定，不重置 _iosVolumeChangeThreshold
      } else {
        _recentSoundLevels = List.filled(8, 30.0);
      }
    });
  }

  // **開始倒數計時**
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 1) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _finishTest(); // 完成測試
      }
    });
  }

  // 完成測試，返回上一畫面
  void _finishTest() {
    _stopListening();
    // 回調通知完成了測試並傳遞字數
    widget.onComplete(_wordCount);
    Navigator.pop(context); // 返回上一畫面
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("正在測試：${widget.selectedPhoneme}"),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildTopInfoPanel(),
              const Spacer(),
              _buildAnimatedBubble(),
              const Spacer(),
              _buildThresholdSlider(),
              const SizedBox(height: 20),
              // iOS 特殊調整滑桿
              if (Platform.isIOS) ...[
                _buildIOSAdjustmentSlider(),
                const SizedBox(height: 15),
              ],
              _buildStartStopButton(),
            ],
          ),
        ),
      ),
    );
  }

  // UI 組件：頂部資訊面板
  Widget _buildTopInfoPanel() {
    return Row(
      children: [
        Expanded(child: _buildCountdownTimer()),
        const SizedBox(width: 20),
        Expanded(child: _buildWordCountDisplay()),
      ],
    );
  }

  // UI 組件：發音動畫氣泡
  Widget _buildAnimatedBubble() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A9BEE), Color(0xFF4A90E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2)
                          .withOpacity(0.4 - (_scaleAnimation.value - 1) / 2),
                      blurRadius: 15 + (_scaleAnimation.value - 1) * 10,
                      spreadRadius: (_scaleAnimation.value - 1) * 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.selectedPhoneme,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          _isListening
              ? (Platform.isIOS ? "請清晰發音並在音節間稍作停頓！" : "請對著麥克風大聲發音！")
              : "點擊「開始測試」以進行錄音",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (_isListening && Platform.isIOS) ...[
          const SizedBox(height: 8),
          Text(
            "iOS 智慧偵測：會自動識別音節間的停頓",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // UI 組件：開始/停止按鈕
  Widget _buildStartStopButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isListening ? _stopListening : _startListening,
        icon: Icon(_isListening ? Icons.stop_circle_outlined : Icons.mic,
            color: Colors.white),
        label: Text(
          _isListening ? '停止測試' : '開始測試',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isListening ? Colors.redAccent : const Color(0xFF4A90E2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // UI 組件：倒數計時器
  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.timer_outlined, color: Colors.black54, size: 20),
              SizedBox(width: 8),
              Text(
                "剩餘時間",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _remainingTime / 10.0,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFF76B6B)),
                ),
                Center(
                  child: Text(
                    "$_remainingTime",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF76B6B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI 組件：音節計數顯示
  Widget _buildWordCountDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.record_voice_over_outlined,
                  color: Colors.black54, size: 20),
              SizedBox(width: 8),
              Text(
                "音節數量",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: Center(
              child: Text(
                "$_wordCount",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                  height: 1.1, // Adjust line height to center better
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI 組件：偵測門檻滑桿
  Widget _buildThresholdSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "偵測靈敏度 (${Platform.isIOS ? 'iOS' : 'Android'})",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                Text(
                  _isListening ? "測試中無法調整" : "可左右滑動調整",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 顯示當前即時音量和平台資訊
          Column(
            children: [
              Text(
                '當前音量: ${_soundLevel.toStringAsFixed(1)} dB',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _soundLevel > _dBThreshold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _soundLevel > _dBThreshold
                      ? Colors.green
                      : Colors.black87,
                ),
              ),
              if (Platform.isIOS && _recentSoundLevels.isNotEmpty) ...[
                Text(
                  '音量變化: ${_calculateVolumeIncrease().toStringAsFixed(1)} dB/樣本',
                  style: TextStyle(fontSize: 11, color: Colors.blue[600]),
                ),
                Text(
                  '靜音計數: $_silentSamples (需要 $_minSilenceGap)',
                  style: TextStyle(fontSize: 11, color: Colors.orange[600]),
                ),
              ],
              Text(
                '平台建議範圍: ${Platform.isIOS ? "50-90" : "60-100"} dB',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4A90E2),
              inactiveTrackColor: Colors.blue[100],
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 4.0,
              thumbColor: const Color(0xFF4A90E2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayColor: const Color(0xFF4A90E2).withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              value: _dBThreshold.clamp(
                  Platform.isIOS ? 50.0 : 60.0, Platform.isIOS ? 90.0 : 100.0),
              min: Platform.isIOS ? 50.0 : 60.0,
              max: Platform.isIOS ? 90.0 : 100.0,
              divisions: Platform.isIOS ? 20 : 20, // 每2dB一個刻度
              label: _dBThreshold.toStringAsFixed(0),
              onChanged: _isListening
                  ? null // 測試進行中不可調整
                  : (value) {
                      setState(() {
                        ///更新 _dBThreshold 的數值
                        _dBThreshold = value;
                        print(
                            '調整音量閾值: $_dBThreshold dB (${Platform.isIOS ? "iOS" : "Android"})');
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }

  // iOS 專用：音量變化靈敏度調整滑桿
  Widget _buildIOSAdjustmentSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "iOS 音節分離靈敏度",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue),
                ),
                Text(
                  _isListening ? "測試中無法調整" : "調整分離效果",
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '當前閾值: ${_iosVolumeChangeThreshold.toStringAsFixed(1)} dB',
            style: TextStyle(fontSize: 13, color: Colors.blue[800]),
          ),
          Text(
            '較低值: 更敏感 | 較高值: 更精確',
            style: TextStyle(fontSize: 11, color: Colors.blue[600]),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.blue[100],
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 3.0,
              thumbColor: Colors.blue,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
              overlayColor: Colors.blue.withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: _iosVolumeChangeThreshold.clamp(5.0, 20.0),
              min: 5.0,
              max: 20.0,
              divisions: 15,
              label: _iosVolumeChangeThreshold.toStringAsFixed(1),
              onChanged: _isListening
                  ? null
                  : (value) {
                      setState(() {
                        _iosVolumeChangeThreshold = value;
                        print('iOS 音量變化閾值調整為: $_iosVolumeChangeThreshold dB');
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    //取消動作
    _noiseSubscription?.cancel();
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

Future<void> endout9({required Map<String, int> completedPhonemes}) async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  var url;
  if (Face_Detect_Number == 9) {
    //抿嘴
    url = Uri.parse(ip + "train_mouthok.php");
    print("初階,吞嚥");
  }
  String final_Phonemes =
      "${completedPhonemes["PA"]}/ ${completedPhonemes["TA"]}/ ${completedPhonemes["KA"]}";
  final responce = await http.post(url, body: {
    "time": formattedDate,
    "account": FFAppState().accountnumber.toString(),
    "action": FFAppState().mouth.toString(), //動作
    "degree": "初階",
    "parts": "吞嚥",
    "times": "1", //動作
    "rsst_test_times": "",
    "PA_TA_KA": final_Phonemes,
    "coin_add": "5",
  });
  if (responce.statusCode == 200) {
    print("ok");
  } else {
    print(responce.statusCode);
    print("no");
  }
}
