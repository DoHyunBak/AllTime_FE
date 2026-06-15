import 'package:flutter/material.dart';

/// Liquid Glass용 배경 — 글래스가 굴절/블러할 '벽지'.
/// 컬러 베이스 그라데이션 + 강조 컬러 블롭(라디얼) 메시.
/// 이 색을 Tier 1 블러와 Tier 2 반투명이 머금어야 글래스가 '읽힌다'.
/// (정적·RepaintBoundary 격리 — shouldRepaint=false 라 비용 거의 0)
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _MeshPainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;

    // 컬러 베이스 그라데이션 (민트 → 페리윙클 → 라일락)
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD2ECDF), Color(0xFFD0DAF5), Color(0xFFE7D6F1)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(full),
    );

    void blob(double cx, double cy, double r, int argb) {
      final center = Offset(size.width * cx, size.height * cy);
      final rect = Rect.fromCircle(center: center, radius: r);
      final color = Color(argb);
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ).createShader(rect),
      );
    }

    final s = size.shortestSide;
    blob(0.12, 0.05, s * 1.00, 0x521DB954); // 브랜드 그린
    blob(0.98, 0.02, s * 0.90, 0x4D3182F6); // 블루
    blob(0.92, 0.60, s * 1.05, 0x4D7C5CFF); // 바이올렛
    blob(0.04, 0.98, s * 0.90, 0x38FF9F45); // 웜 앰버
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => false;
}
