import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 네트워크 연결 상태를 스트림으로 제공
///
/// 원칙: 현장(Field)에서의 열악한 네트워크 환경 대응
/// - 연결 끊김 즉시 오프라인 배너 표시
/// - 재연결 시 자동 동기화 트리거
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// 현재 오프라인 여부 (boolean)
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) =>
        results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
});
