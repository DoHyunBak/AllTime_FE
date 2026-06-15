import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'liquid_glass.dart';

/// ─────────────────────────────────────────────────────────────
/// TossColors — 타입드 디자인 토큰 (ThemeExtension)
/// 접근: Theme.of(context).extension<TossColors>()!
/// ─────────────────────────────────────────────────────────────
@immutable
class TossColors extends ThemeExtension<TossColors> {
  const TossColors({
    required this.brand,
    required this.brandWash,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDimmed,
    required this.borderLight,
    required this.borderStrong,
    required this.canvas,
    required this.secondaryBackground,
    required this.liftedSurface,
  });

  final Color brand; // #3182f6
  final Color brandWash; // #e8f3ff
  final Color textPrimary; // #191f28
  final Color textSecondary; // #333d4b
  final Color textMuted; // #6b7684
  final Color textDimmed; // #8b95a1
  final Color borderLight; // #e5e8eb
  final Color borderStrong; // #d1d6db
  final Color canvas; // #ffffff
  final Color secondaryBackground; // #f9fafb
  final Color liftedSurface; // #f2f4f6

  static const light = TossColors(
    brand: AppColors.primary,
    brandWash: AppColors.primaryBg,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    textDimmed: AppColors.textDimmed,
    borderLight: AppColors.borderLight,
    borderStrong: AppColors.borderButton,
    canvas: AppColors.bgSurface,
    secondaryBackground: AppColors.bgBase,
    liftedSurface: AppColors.bgElevated,
  );

  @override
  TossColors copyWith({
    Color? brand,
    Color? brandWash,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDimmed,
    Color? borderLight,
    Color? borderStrong,
    Color? canvas,
    Color? secondaryBackground,
    Color? liftedSurface,
  }) {
    return TossColors(
      brand: brand ?? this.brand,
      brandWash: brandWash ?? this.brandWash,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDimmed: textDimmed ?? this.textDimmed,
      borderLight: borderLight ?? this.borderLight,
      borderStrong: borderStrong ?? this.borderStrong,
      canvas: canvas ?? this.canvas,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      liftedSurface: liftedSurface ?? this.liftedSurface,
    );
  }

  @override
  TossColors lerp(ThemeExtension<TossColors>? other, double t) {
    if (other is! TossColors) return this;
    return TossColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandWash: Color.lerp(brandWash, other.brandWash, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDimmed: Color.lerp(textDimmed, other.textDimmed, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      liftedSurface: Color.lerp(liftedSurface, other.liftedSurface, t)!,
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// TossPressable — 탭 시 0.98 스케일 다운(96ms ease-out) + 라이트 햅틱.
/// 기본 InkWell 리플 대신 사용하는 물리적 마이크로 인터랙션.
/// ─────────────────────────────────────────────────────────────
class TossPressable extends StatefulWidget {
  const TossPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.haptic = true,
    this.scale = 0.98,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;
  final double scale;

  @override
  State<TossPressable> createState() => _TossPressableState();
}

class _TossPressableState extends State<TossPressable>
    with SingleTickerProviderStateMixin {
  // unbounded: 스프링이 살짝 오버슈트해도 클램프되지 않도록
  late final AnimationController _c =
      AnimationController.unbounded(vsync: this, value: 1.0);

  // 탄성/감쇠 — 빠릿하면서 미세한 바운스
  static const _spring =
      SpringDescription(mass: 1, stiffness: 520, damping: 22);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // 현재 value와 velocity에서 목표로 스프링 구동 → 빠른 연타 시 모멘텀 보존
  void _springTo(double target) {
    _c.animateWith(SpringSimulation(_spring, _c.value, target, _c.velocity));
  }

  void _down(_) => _springTo(widget.scale);
  void _up([_]) => _springTo(1.0);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: enabled ? _down : null,
        onTapUp: enabled ? _up : null,
        onTapCancel: enabled ? _up : null,
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              }
            : null,
        child: ScaleTransition(scale: _c, child: widget.child),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// TossButton — primary / secondary / danger. 7px 라운드, elevation 0.
/// ─────────────────────────────────────────────────────────────
enum TossButtonVariant { primary, secondary, danger }

class TossButton extends StatelessWidget {
  const TossButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = TossButtonVariant.primary,
    this.full = true,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final TossButtonVariant variant;
  final bool full;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      TossButtonVariant.primary => (AppColors.primary, Colors.white),
      TossButtonVariant.secondary => (
          AppColors.primaryBg,
          AppColors.primaryDim
        ),
      TossButtonVariant.danger => (AppColors.error, Colors.white),
    };
    final active = enabled && !loading;

    return TossPressable(
      onTap: active ? onTap : null,
      child: Opacity(
        opacity: active ? 1.0 : 0.4,
        child: LiquidSpecular(
          borderRadius: 7,
          child: Container(
            width: full ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation(fg)),
                  )
                : Text(label,
                    style: TextStyle(
                        color: fg, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Appear — 진입 시 fade + slide-up 등장. index로 stagger(순차) 지연.
/// ─────────────────────────────────────────────────────────────
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 14,
  });

  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final double offsetY;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delayStep * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * widget.offsetY),
          child: child,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// DelayedReveal — [duration] 동안 [skeleton]을 보여준 뒤 [child]로 전환.
/// 각 화면을 stateful로 바꾸지 않고도 "스켈레톤→콘텐츠" 로딩 경험 제공.
/// ─────────────────────────────────────────────────────────────
class DelayedReveal extends StatefulWidget {
  const DelayedReveal({
    super.key,
    required this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget skeleton;
  final Widget child;
  final Duration duration;

  @override
  State<DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<DelayedReveal> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: _ready ? widget.child : widget.skeleton,
    );
  }
}

/// 큰 숫자 + 작은 단위(Toss 패턴) 텍스트.
class MetricText extends StatelessWidget {
  const MetricText({
    super.key,
    required this.value,
    required this.unit,
    this.valueSize = 26,
    this.color,
    this.unitColor,
  });
  final String value;
  final String unit;
  final double valueSize;
  final Color? color;
  final Color? unitColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.0,
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              fontSize: valueSize * 0.5,
              fontWeight: FontWeight.w600,
              color: unitColor ?? AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// ShimmerLoader — ShaderMask 스위핑 그라데이션(리퀴드 메탈 시머).
/// 스피너 대신 사용하는 로딩 상태. 웹 안전(외부 셰이더/에셋 불필요).
/// ─────────────────────────────────────────────────────────────
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1300),
  });

  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final base = widget.baseColor ?? AppColors.bgElevated;
    final highlight = widget.highlightColor ?? AppColors.bgSurface;

    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value; // 0..1 좌→우 스윕
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SweepTranslate(dx * (t * 2 - 1)),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SweepTranslate extends GradientTransform {
  const _SweepTranslate(this.dx);
  final double dx;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// ─────────────────────────────────────────────────────────────
/// FuturisticLoader — 스피너 대체용 회전 스위프 링(브랜드 그린).
/// 연속 회전 + 가속/감속 커브로 유기적인 로딩 모션. 의존성/에셋 없음.
/// ─────────────────────────────────────────────────────────────
class FuturisticLoader extends StatefulWidget {
  const FuturisticLoader(
      {super.key, this.size = 36, this.color, this.strokeWidth = 3.5});
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  State<FuturisticLoader> createState() => _FuturisticLoaderState();
}

class _FuturisticLoaderState extends State<FuturisticLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: _SweepRingPainter(_c.value, color, widget.strokeWidth),
          ),
        ),
      ),
    );
  }
}

class _SweepRingPainter extends CustomPainter {
  _SweepRingPainter(this.t, this.color, this.stroke);
  final double t;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;
    final start = t * 6.2831853; // 회전

    // 트랙
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    // 그라데이션 스위프 아크
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 6.2831853,
        colors: [color.withValues(alpha: 0.0), color],
        transform: GradientRotation(start),
      ).createShader(rect);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, 4.4,
        false, sweep);
  }

  @override
  bool shouldRepaint(covariant _SweepRingPainter old) =>
      old.t != t || old.color != color;
}

/// 시머가 적용된 스켈레톤 블록 (로딩 자리표시자).
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
