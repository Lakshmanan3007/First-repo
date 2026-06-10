import 'package:flutter/material.dart';

import 'core/di/app_services.dart';
import 'core/theme/trace_theme.dart';
import 'features/about/about_screen.dart';
import 'features/splash/splash_screen.dart';
import 'navigation/app_shell.dart';
import 'navigation/routes.dart';

class TraceApp extends StatelessWidget {

  const TraceApp({super.key});

  @override

  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppServices.instance.settings,
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'TRACE',
          debugShowCheckedModeBanner: false,
          theme: TraceTheme.light,
          darkTheme: TraceTheme.dark,
          themeMode: settings.materialThemeMode,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.home: (_) => const AppShell(),
            AppRoutes.about: (_) => const AboutScreen(),
          },
        );
      },
    );
  }

}


