import 'package:flutter/material.dart';

/// 앱 전체를 700×1400 논리 해상도로 고정 렌더링하는 프레임.
///
/// 실제 창/화면 크기와 무관하게 모든 화면이 700×1400 기준으로 레이아웃되며,
/// 가용 영역에 맞춰 비율을 유지한 채 스케일됩니다. (웹/데스크톱에서 모바일 비율 유지)
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.child});

  /// 기준 논리 해상도
  static const double frameWidth = 700;
  static const double frameHeight = 1400;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF000000),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: frameWidth,
            height: frameHeight,
            child: ClipRect(
              child: MediaQuery(
                // 내부 위젯들이 700×1400을 화면 크기로 인식하도록 오버라이드
                data: MediaQuery.of(context).copyWith(
                  size: const Size(frameWidth, frameHeight),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// MaterialApp 의 `builder` 에 그대로 넘길 수 있는 헬퍼.
Widget deviceFrameBuilder(BuildContext context, Widget? child) {
  return DeviceFrame(child: child ?? const SizedBox.shrink());
}
