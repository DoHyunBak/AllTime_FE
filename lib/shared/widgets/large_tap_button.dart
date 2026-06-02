import 'package:flutter/material.dart';

/// 큰 터치 타겟 버튼 — .btn 디자인 시스템 구현
///
/// CSS:
///   background: #FAF9F5
///   border: 0.57px solid rgba(31, 30, 29, 0.4)
///   border-radius: 12px
///   padding: 12px 16px
///   font-size: 14px
class LargeTapButton extends StatelessWidget {
  const LargeTapButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = const Color(0xFFFAF9F5),
    this.textColor = const Color(0xFF14140F),
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(
            color: Color(0x661F1E1D), // rgba(31,30,29,0.4)
            width: 0.57,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
