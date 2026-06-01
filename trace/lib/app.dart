import 'package:flutter/material.dart';

import 'core/theme/trace_theme.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/splash/splash_screen.dart';
import 'navigation/app_shell.dart';
import 'navigation/routes.dart';

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRACE',
      debugShowCheckedModeBanner: false,
      theme: TraceTheme.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingFlow(),
        AppRoutes.home: (_) => const AppShell(),
      },
    );
  }
}
