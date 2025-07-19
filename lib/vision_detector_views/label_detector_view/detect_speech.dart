import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../trainmouth/trainmouth_widget.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:intl/intl.dart';

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
  double _dBThreshold = 80.0;

  // 平台特定的音量處理
  Timer? _volumeDecayTimer;
  double _lastSignificantVolume = 0.0;
  DateTime _lastVolumeUpdate = DateTime.now();
  static const int _volumeDecayDuration = 200; // iOS音量衰減間隔(毫秒)
  static const double _volumeDecayRate = 0.85; // iOS音量衰減係數

  // 動畫控制
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 倒數計時
  Timer? _countdownTimer;
  int _remainingTime = 10; // 設定倒數 10 秒

  @override
  void initState() {
    super.initState();
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

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _startListening() {
    if (_isListening) return;

    _resetValues(); // 重置計數與變數
    _noiseMeter ??= NoiseMeter();

    try {
      // 開始監聽音量
      _noiseSubscription = _noiseMeter!.noiseStream.listen((noiseEvent) {
        _processVolumeData(noiseEvent.meanDecibel);
      }, onError: (e) {
        debugPrint('噪音偵測錯誤：$e');
        _stopListening();
      });

      // 開始倒數計時
      _startCountdown();
    } catch (e) {
      debugPrint('啟動偵測時發生錯誤：$e');
      _stopListening();
    }

    setState(() => _isListening = true);
  }

  // 處理音量數據，針對iOS進行優化
  void _processVolumeData(double newVolume) {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastVolumeUpdate).inMilliseconds;
    
    // 根據平台調整音量處理策略
    if (io.Platform.isIOS) {
      // iOS 平台：增強響應速度和音量衰減
      if (newVolume > _lastSignificantVolume || timeDiff > 100) {
        // 如果音量增加或距離上次更新超過100ms，立即更新
        _updateVolumeLevel(newVolume);
        _lastSignificantVolume = newVolume;
        _lastVolumeUpdate = now;
        
        // 取消之前的衰減定時器
        _volumeDecayTimer?.cancel();
        
        // 設置新的衰減定時器，讓音量更快速下降
        _volumeDecayTimer = Timer.periodic(
          Duration(milliseconds: _volumeDecayDuration),
          (timer) {
            if (!_isListening) {
              timer.cancel();
              return;
            }
            
            final decayedVolume = _soundLevel * _volumeDecayRate;
            if (decayedVolume < 65.0) { // 底線音量
              timer.cancel();
              _updateVolumeLevel(65.0);
            } else {
              _updateVolumeLevel(decayedVolume);
            }
          }
        );
      }
    } else {
      // Android 平台：使用原有邏輯
      _updateVolumeLevel(newVolume);
    }
  }

  // 統一的音量更新方法
  void _updateVolumeLevel(double volume) {
    setState(() {
      _soundLevel = volume;

      if (_soundLevel > _dBThreshold) {
        if (!_hasAddedWord) {
          _wordCount++;
          _hasAddedWord = true;
        }
        _animationController.forward(); // 氣泡放大
      } else {
        _hasAddedWord = false;
        _animationController.reverse(); // 氣泡縮小
      }
    });
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
    _countdownTimer?.cancel(); // 停止倒數
    _volumeDecayTimer?.cancel(); // 停止音量衰減定時器
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
          _isListening ? "請對著麥克風大聲發音！" : "點擊「開始測試」以進行錄音",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
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
                const Text(
                  "偵測靈敏度",
                  style: TextStyle(
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
          // 顯示當前音量和門檻值
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "當前音量: ${_soundLevel.toStringAsFixed(1)} dB",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _soundLevel > _dBThreshold ? FontWeight.bold : FontWeight.normal,
                    color: _soundLevel > _dBThreshold ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                Text(
                  "門檻: ${_dBThreshold.toStringAsFixed(0)} dB",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          // 音量進度條
          if (_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "60",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.grey[200],
                          ),
                          child: Stack(
                            children: [
                              // 音量進度條
                              FractionallySizedBox(
                                widthFactor: ((_soundLevel - 60) / 40).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: _soundLevel > _dBThreshold 
                                        ? Colors.green[500] 
                                        : Colors.orange[500],
                                  ),
                                ),
                              ),
                              // 門檻線
                              FractionallySizedBox(
                                widthFactor: (_dBThreshold - 60) / 40,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 2,
                                    height: 6,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "100",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _soundLevel > _dBThreshold ? "✓ 已觸發偵測" : "等待聲音輸入",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _soundLevel > _dBThreshold ? FontWeight.bold : FontWeight.normal,
                      color: _soundLevel > _dBThreshold ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
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
            child: Stack(
              children: [
                // 主要的門檻值滑桿
                Slider(
                  value: _dBThreshold,
                  min: 60,
                  max: 100,
                  divisions: 40, // 將範圍切成 40 份
                  label: _dBThreshold.toStringAsFixed(0),
                  onChanged: _isListening
                      ? null // 測試進行中不可調整
                      : (value) {
                          setState(() {
                            ///更新 _dBThreshold 的數值
                            _dBThreshold = value;
                          });
                        },
                ),
                // 當前音量指示器
                if (_isListening && _soundLevel >= 60 && _soundLevel <= 100)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.0,
                          thumbColor: _soundLevel > _dBThreshold 
                              ? Colors.green[600] 
                              : Colors.orange[600],
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: _soundLevel > _dBThreshold ? 10.0 : 8.0,
                          ),
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _soundLevel.clamp(60.0, 100.0),
                          min: 60,
                          max: 100,
                          onChanged: null, // 只用於顯示，不可互動
                        ),
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

  @override
  void dispose() {
    //取消動作
    _noiseSubscription?.cancel();
    _animationController.dispose();
    _countdownTimer?.cancel();
    _volumeDecayTimer?.cancel(); // 清理音量衰減定時器
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
