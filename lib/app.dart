import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'shared/widgets/device_frame.dart';

class AllTimeApp extends ConsumerStatefulWidget {
  const AllTimeApp({super.key});

  @override
  ConsumerState<AllTimeApp> createState() => _AllTimeAppState();
}

class _AllTimeAppState extends ConsumerState<AllTimeApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    if (_showSplash) {
      return MaterialApp(
        title: 'AllTime',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light, // 라이트모드 고정 (다크모드 미지원)
        builder: deviceFrameBuilder,
        home: SplashScreen(onComplete: () => setState(() => _showSplash = false)),
      );
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AllTime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light, // 라이트모드 고정 (다크모드 미지원)
      builder: deviceFrameBuilder,
      routerConfig: router,
    );
  }
}
