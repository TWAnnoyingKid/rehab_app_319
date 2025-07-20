import 'package:flutter/material.dart';
import 'dart:math' as math;

class NativeWaveformWidget extends StatefulWidget {
  final List<double> waveformData;
  final double height;
  final double width;
  final Color waveColor;
  final Color backgroundColor;
  final double strokeWidth;
  final bool showMiddleLine;
  final int maxPoints;

  const NativeWaveformWidget({
    Key? key,
    required this.waveformData,
    this.height = 60,
    this.width = 300,
    this.waveColor = Colors.blue,
    this.backgroundColor = Colors.transparent,
    this.strokeWidth = 2.0,
    this.showMiddleLine = true,
    this.maxPoints = 50,
  }) : super(key: key);

  @override
  State<NativeWaveformWidget> createState() => _NativeWaveformWidgetState();
}

class _NativeWaveformWidgetState extends State<NativeWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void didUpdateWidget(NativeWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waveformData.length != widget.waveformData.length) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: NativeWaveformPainter(
              waveformData: widget.waveformData,
              waveColor: widget.waveColor,
              strokeWidth: widget.strokeWidth,
              showMiddleLine: widget.showMiddleLine,
              maxPoints: widget.maxPoints,
              animationValue: _animation.value,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class NativeWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color waveColor;
  final double strokeWidth;
  final bool showMiddleLine;
  final int maxPoints;
  final double animationValue;

  NativeWaveformPainter({
    required this.waveformData,
    required this.waveColor,
    required this.strokeWidth,
    required this.showMiddleLine,
    required this.maxPoints,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final middlePaint = Paint()
      ..color = waveColor.withOpacity(0.3)
      ..strokeWidth = 1;

    final centerY = size.height / 2;

    // 繪製中線
    if (showMiddleLine) {
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        middlePaint,
      );
    }

    if (waveformData.isEmpty) return;

    // 限制數據點數量並準備數據
    List<double> displayData = waveformData.length > maxPoints
        ? waveformData.sublist(waveformData.length - maxPoints)
        : waveformData;

    if (displayData.isEmpty) return;

    // 計算每個點的間距
    final double stepWidth = size.width / (maxPoints - 1);

    // 如果數據點不足，重複最後一個值
    while (displayData.length < maxPoints) {
      displayData.add(displayData.isNotEmpty ? displayData.last : 0.0);
    }

    // 繪製波形
    for (int i = 0; i < displayData.length; i++) {
      final double x = i * stepWidth;

      // 將音頻數據轉換為波形高度 (0.0-1.0 -> 0 到 height/2)
      double amplitude = displayData[i];

      // 限制振幅並放大以便可視化
      amplitude = math.min(amplitude, 1.0) * size.height * 0.4;

      // 應用動畫效果
      amplitude *= animationValue;

      // 繪製從中心向上和向下的線條
      final double topY = centerY - amplitude;
      final double bottomY = centerY + amplitude;

      // 創建漸變效果
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            waveColor.withOpacity(0.8),
            waveColor,
            waveColor.withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTRB(x, topY, x + strokeWidth, bottomY))
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, topY),
        Offset(x, bottomY),
        gradientPaint,
      );

      // 添加峰值點效果
      if (amplitude > size.height * 0.2) {
        final peakPaint = Paint()
          ..color = waveColor.withOpacity(0.6)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x, topY),
          strokeWidth * 0.5,
          peakPaint,
        );
        canvas.drawCircle(
          Offset(x, bottomY),
          strokeWidth * 0.5,
          peakPaint,
        );
      }
    }

    // 添加波形頂部的光暈效果
    final glowPaint = Paint()
      ..color = waveColor.withOpacity(0.2)
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < displayData.length; i++) {
      final double x = i * stepWidth;
      double amplitude =
          math.min(displayData[i], 1.0) * size.height * 0.4 * animationValue;

      if (amplitude > size.height * 0.1) {
        canvas.drawLine(
          Offset(x, centerY - amplitude),
          Offset(x, centerY + amplitude),
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NativeWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.waveColor != waveColor;
  }
}
