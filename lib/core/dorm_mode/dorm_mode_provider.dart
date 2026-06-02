import 'package:flutter_riverpod/flutter_riverpod.dart';

class DormModeState {
  const DormModeState({this.isActive = false, this.dormName = ''});
  final bool isActive;
  final String dormName;
}

class DormModeNotifier extends StateNotifier<DormModeState> {
  DormModeNotifier() : super(const DormModeState());

  // NFC 태깅 시 호출 (실제: nfc_manager 패키지로 태그 감지)
  void activate(String dormName) {
    state = DormModeState(isActive: true, dormName: dormName);
  }

  void deactivate() {
    state = const DormModeState();
  }
}

final dormModeProvider = StateNotifierProvider<DormModeNotifier, DormModeState>((ref) {
  return DormModeNotifier();
});
