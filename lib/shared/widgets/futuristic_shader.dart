import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 탭 지점에서 GPU 프래그먼트 셰이더(liquid_effect.frag)로
/// 유기적 리플/네온 글로우를 그리는 래퍼.
///
/// - uTime(0), uResolution(1,2), uTouchPoint(3,4), uProgress(5) 유니폼 전달
/// - 연속 Ticker로 uTime, 탭마다 AnimationController로 uProgress 0→1
/// - RepaintBoundary로 메인 스레드 리페인트 격리, dispose로 리소스 정리
class FuturisticShaderTouchWrapper extends StatefulWidget {
  const FuturisticShaderTouchWrapper({
    super.key,
    required this.child,
    this.haptic = true,
  });

  final Widget child;
  final bool haptic;

  @override
  State<FuturisticShaderTouchWrapper> createState() => _FuturisticShaderTouchWrapperState();
}

class _FuturisticShaderTouchWrapperState extends State<FuturisticShaderTouchWrapper>
    with TickerProviderStateMixin {
  ui.FragmentShader? _shader;

  late final AnimationController _ripple =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  // 연속 시간 소스 (uTime)
  late final AnimationController _time =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  Offset _touch = Offset.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/liquid_effect.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // 셰이더 미지원 환경(일부 플랫폼) → child만 표시
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    _time.dispose();
    _shader?.dispose();
    super.dispose();
  }

  void _onDown(PointerDownEvent e) {
    _touch = e.localPosition;
    if (widget.haptic) HapticFeedback.lightImpact();
    _ripple.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return Listener(
      onPointerDown: _onDown,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (shader != null)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _RipplePainter(
                      shader: shader,
                      repaint: Listenable.merge([_ripple, _time]),
                      progress: _ripple,
                      time: _time,
                      touch: () => _touch,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.shader,
    required Listenable repaint,
    required this.progress,
    required this.time,
    required this.touch,
  }) : super(repaint: repaint);

  final ui.FragmentShader shader;
  final Animation<double> progress;
  final AnimationController time;
  final Offset Function() touch;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress.isDismissed) return; // 리플 비활성 시 페인트 스킵
    final p = touch();
    shader
      ..setFloat(0, time.value * 4.0)   // uTime (초)
      ..setFloat(1, size.width)         // uResolution.x
      ..setFloat(2, size.height)        // uResolution.y
      ..setFloat(3, p.dx)               // uTouchPoint.x
      ..setFloat(4, p.dy)               // uTouchPoint.y
      ..setFloat(5, progress.value);    // uProgress [0..1]

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => true;
}
