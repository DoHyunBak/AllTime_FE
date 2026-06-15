import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// WWDC 2025 'Liquid Glass'의 Flutter 네이티브 구현.
///
/// 웹 스펙(SVG feDisplacementMap / CSS backdrop-filter / box-shadow:inset)을
/// Flutter 비용 모델에 맞춰 2-Tier로 옮긴 전역 글래스 프리미티브.
///
///  * [LiquidGlassTier.tier1] — 진짜 `BackdropFilter` 블러.
///    내비/탭바/대형 모달 등 **인스턴스 소수** 표면 전용.
///  * [LiquidGlassTier.tier2] — 블러 위젯 없이 반투명 프로스티드 틴트 + 스페큘러로
///    "흉내". 카드/버튼/배너 등 **인스턴스 다수** 표면 전용. (60fps 방어)
///
/// 모서리는 Apple식 'Convex Squircle'(연속 곡률)을 위해 [ContinuousRectangleBorder]
/// 를 쓰고, 스페큘러 하이라이트가 **동일한 외곽 경로**(getOuterPath)를 따라가
/// 픽셀 정렬된다.
enum LiquidGlassTier { tier1, tier2 }

class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.tier = LiquidGlassTier.tier2,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.tint,
    this.blurSigma,
    this.border,
    this.shadow = true,
  });

  final Widget child;
  final LiquidGlassTier tier;

  /// 'RoundedRectangle 환산' 반경. 내부에서 연속 곡률용으로 [_continuousScale]
  /// 만큼 보정한다. `0`이면 모서리 없는 바(헤더/탭바)로 동작.
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  /// 프로스티드 틴트 색 오버라이드(null이면 Tier 기본값).
  final Color? tint;

  /// 블러 시그마 오버라이드(null이면 Tier 기본값. Tier 2는 기본 0).
  final double? blurSigma;

  /// 바처럼 단일 모서리 보더가 필요할 때 주입(예: `Border(bottom: ...)`).
  /// null이면 카드용 하이라인 보더를 스페큘러 페인터가 그린다.
  final BoxBorder? border;

  /// Tier 2 카드의 소프트 드롭 섀도우(평면 배경 위 분리감).
  final bool shadow;

  /// RoundedRectangle → ContinuousRectangle 시각 보정 계수.
  /// (연속 곡률은 같은 반경값에서 더 타이트하게 보여 ~1.6× 보정)
  static const double _continuousScale = 1.6;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spec = _LiquidGlassSpec.of(tier, isDark);
    final sigma = blurSigma ?? spec.blur;
    final scaledRadius = borderRadius * _continuousScale;

    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(scaledRadius),
    );

    Widget surface = CustomPaint(
      foregroundPainter: _SpecularPainter(
        shape: shape,
        radius: borderRadius,
        specular: spec.specular,
        borderColor: spec.border,
        drawBorder: border == null,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: tint ?? spec.tint, border: border),
        // ListTile 등 Material 잉크가 반투명 면 위에서도 보이도록 투명 Material 제공
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );

    Widget clipped = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: sigma > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: surface,
            )
          : surface,
    );

    if (shadow && tier == LiquidGlassTier.tier2 && borderRadius > 0) {
      clipped = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scaledRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: clipped,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: clipped,
    );
  }
}

/// 자체 배경색을 가진 Tier 2 요소(버튼/배너/필) 위에 **스페큘러 상단 하이라이트만**
/// 얹는 오버레이. 표면을 글래스로 바꾸지 않고 빛 반사 느낌만 더한다.
/// CustomPaint의 foregroundPainter라 포인터(탭)는 자식이 그대로 받는다.
class LiquidSpecular extends StatelessWidget {
  const LiquidSpecular({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.strength = 0.85,
  });

  final Widget child;
  final double borderRadius;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(
        borderRadius * LiquidGlass._continuousScale,
      ),
    );
    return CustomPaint(
      foregroundPainter: _SpecularPainter(
        shape: shape,
        radius: borderRadius,
        specular: strength,
        borderColor: Colors.transparent,
        drawBorder: false,
      ),
      child: child,
    );
  }
}

/// Tier 1 모달 — 뒤 배경을 프로스티드 블러로 깔고 다이얼로그를 페이드/스케일로 등장.
/// 호출부는 `showDialog`를 그대로 대체(동일 named 파라미터)한다.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.22),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return Stack(
        alignment: Alignment.center,
        children: [
          // 전체 화면 프로스티드 배경(배리어 위). IgnorePointer로 탭은 배리어가 처리.
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 14 * curved.value,
                  sigmaY: 14 * curved.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          FadeTransition(
            opacity: curved,
            child: Transform.scale(
              scale: 0.96 + 0.04 * curved.value,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

/// Tier별 글래스 파라미터(블러/틴트/스페큘러/보더).
class _LiquidGlassSpec {
  const _LiquidGlassSpec({
    required this.blur,
    required this.tint,
    required this.specular,
    required this.border,
  });

  final double blur;
  final Color tint;
  final double specular;
  final Color border;

  static _LiquidGlassSpec of(LiquidGlassTier tier, bool isDark) {
    switch (tier) {
      case LiquidGlassTier.tier1:
        return isDark
            ? _LiquidGlassSpec(
                blur: 24,
                tint: AppColors.bgSurfaceDark.withValues(alpha: 0.55),
                specular: 0.9,
                border: Colors.white.withValues(alpha: 0.12),
              )
            : _LiquidGlassSpec(
                blur: 24,
                tint: Colors.white.withValues(alpha: 0.52),
                specular: 1.0,
                border: Colors.white.withValues(alpha: 0.6),
              );
      case LiquidGlassTier.tier2:
        return isDark
            ? _LiquidGlassSpec(
                blur: 0,
                tint: AppColors.bgSurfaceDark.withValues(alpha: 0.46),
                specular: 0.7,
                border: Colors.white.withValues(alpha: 0.08),
              )
            : _LiquidGlassSpec(
                blur: 0,
                tint: Colors.white.withValues(alpha: 0.5),
                specular: 1.0,
                border: AppColors.borderLight,
              );
    }
  }
}

/// 스페큘러 하이라이트 + 하이라인 보더를 **클립 내부**에 그린다.
/// 외곽 경로의 바깥 절반은 클립으로 잘려 나가 ~0.5–0.7px 이너 스트로크가 되며,
/// 이것이 `box-shadow: inset 0 1px 1px rgba(255,255,255,.6)`의 등가 효과다.
class _SpecularPainter extends CustomPainter {
  _SpecularPainter({
    required this.shape,
    required this.radius,
    required this.specular,
    required this.borderColor,
    required this.drawBorder,
  });

  final ContinuousRectangleBorder shape;
  final double radius; // 0이면 바(상단 라인), >0이면 스쿼클 림
  final double specular;
  final Color borderColor;
  final bool drawBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);

    canvas.save();
    canvas.clipPath(path);

    if (radius > 0) {
      // 상단이 밝고 중단에서 소멸하는 수직 그라데이션 스트로크 = 볼록 렌즈 림 광택
      final highlight = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.6 * specular),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45],
        ).createShader(rect);
      canvas.drawPath(path, highlight);

      // 하단 가장자리 미세 음영 — 유리의 볼록(convex) 깊이감
      final depth = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [
            Colors.black.withValues(alpha: 0.06 * specular),
            Colors.black.withValues(alpha: 0.0),
          ],
        ).createShader(rect);
      canvas.drawPath(path, depth);
    } else {
      // 바(헤더/탭바): 상단 1px 스페큘러 라인
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, 1.0),
        Paint()..color = Colors.white.withValues(alpha: 0.5 * specular),
      );
    }

    // 카드 하이라인 보더(클립 내부 풀패스 스트로크)
    if (drawBorder && radius > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = borderColor,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpecularPainter old) =>
      old.radius != radius ||
      old.specular != specular ||
      old.borderColor != borderColor ||
      old.drawBorder != drawBorder;
}
