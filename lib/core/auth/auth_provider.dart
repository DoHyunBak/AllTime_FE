import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_model.dart';

// Mock 유저 데이터
final _mockStudentUser = const AppUser(
  id: 'student_001',
  name: '박도현',
  email: 'student@univ.ac.kr',
  role: UserRole.student,
  school: '한양대(ERICA)',
  dormitory: '인재관',
  loginProvider: LoginProvider.google,
);

final _mockAdminUser = const AppUser(
  id: 'admin_001',
  name: '기숙사 관리자',
  email: 'admin@univ.ac.kr',
  role: UserRole.admin,
  school: '한양대(ERICA)',
  dormitory: '전체',
  loginProvider: LoginProvider.google,
);

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  Future<void> loginMock(LoginProvider provider, {bool asAdmin = false, bool skipVerification = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final base = asAdmin ? _mockAdminUser : _mockStudentUser;
    state = base.copyWith(isSchoolVerified: skipVerification || asAdmin);
  }

  void logout() {
    state = null;
  }

  void verifySchool() {
    if (state == null) return;
    state = state!.copyWith(isSchoolVerified: true);
  }

  void addDiscountCoupon() {
    if (state == null) return;
    state = state!.copyWith(discountCoupons: state!.discountCoupons + 1);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider)?.isAdmin ?? false;
});
