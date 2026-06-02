import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212), // Deepest dark
        gradient: RadialGradient(
          center: Alignment(-1.0, -1.0), // Top Left
          radius: 1.8,
          colors: [
            Color(0xFF1F3324), // Subtle dark green tint for glassmorphism
            Color(0xFF121212),
            Color(0xFF0A0A0A),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
