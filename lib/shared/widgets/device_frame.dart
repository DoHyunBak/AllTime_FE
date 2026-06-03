import 'package:flutter/material.dart';

/// 앱 전체를 실제 모바일 폰 논리 해상도(393×852, iPhone 15급)로 고정 렌더링하는 프레임.
///
/// 실제 창/화면 크기와 무관하게 모든 화면이 393×852 기준으로 레이아웃되며,
/// 가용 영역에 맞춰 비율을 유지한 채 스케일됩니다.
/// → 웹/데스크톱에서도 모바일 앱과 동일한(확대된) 화면을 보장합니다.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.child});

  /// 기준 논리 해상도 (실제 폰 크기 → 콘텐츠가 앱처럼 크게 보임)
  static const double frameWidth = 393;
  static const double frameHeight = 852;

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
                // 내부 위젯들이 393×852를 화면 크기로 인식하도록 오버라이드
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
