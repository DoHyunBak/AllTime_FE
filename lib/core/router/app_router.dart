import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/school_verify_screen.dart';
import '../../features/main_shell/main_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/facility/presentation/facility_screen.dart';
import '../../features/survey/presentation/survey_screen.dart';
import '../../features/inter_school/presentation/inter_school_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/payment_method_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/terms_of_service_screen.dart';

import '../../features/community/presentation/board_detail_screen.dart';
import '../../features/community/presentation/post_detail_screen.dart';
import '../../features/reservation/presentation/reservation_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState != null ? '/' : '/login',
    redirect: (context, state) {
      final loggedIn = authState != null;
      final isVerified = authState?.isSchoolVerified ?? false;
      final loc = state.matchedLocation;

      if (!loggedIn && loc != '/login') return '/login';
      if (loggedIn && loc == '/login') return isVerified ? '/' : '/verify';
      if (loggedIn && !isVerified && loc != '/verify') return '/verify';
      if (loggedIn && isVerified && loc == '/verify') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/verify', builder: (_, __) => const SchoolVerifyScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsOfServiceScreen()),
      GoRoute(path: '/payment-method', builder: (_, __) => const PaymentMethodScreen()),
      GoRoute(path: '/reservation', builder: (_, __) => const ReservationScreen()),
      GoRoute(
        path: '/board/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BoardDetailScreen(boardId: id);
        },
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
          GoRoute(path: '/facility', builder: (_, __) => const FacilityScreen()),
          GoRoute(path: '/survey', builder: (_, __) => const SurveyScreen()),
          GoRoute(path: '/network', builder: (_, __) => const InterSchoolScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
