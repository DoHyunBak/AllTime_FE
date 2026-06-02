import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Opacity(
            opacity: _fadeIn.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 로고 이미지 ───────────────────────────────
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ── 앱 이름 ───────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'ALL', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1.0)),
                        TextSpan(text: 'TIME', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -1.0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '기숙사 생활의 모든 것',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted, letterSpacing: 0.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 60),
                  // ── 로딩 인디케이터 ───────────────────────────
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
