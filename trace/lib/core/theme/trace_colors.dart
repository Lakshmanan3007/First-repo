import 'package:flutter/material.dart';

/// Monochrome design tokens from UI/trace and UI/operational_intelligence DESIGN.md.
abstract final class TraceColors {
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9F9FB);
  static const Color onBackground = Color(0xFF1A1C1D);
  static const Color onSurface = Color(0xFF1A1C1D);
  static const Color onSurfaceVariant = Color(0xFF4C4546);
  static const Color secondary = Color(0xFF5C5F60);
  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);
  static const Color surface = Color(0xFFF9F9FB);
  static const Color surfaceDim = Color(0xFFD9DADC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F5);
  static const Color surfaceContainer = Color(0xFFEDEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color statusSuccess = Color(0xFFE7F3EC);
  static const Color statusTextSuccess = Color(0xFF166534);
  static const Color statusWarningLow = Color(0xFFFEF7E0);
  static const Color statusTextWarningLow = Color(0xFF854D0E);
  static const Color statusWarningHigh = Color(0xFFFFEDD5);
  static const Color statusTextWarningHigh = Color(0xFF9A3412);
  static const Color statusCritical = Color(0xFFFEE2E2);
  static const Color statusTextCritical = Color(0xFF991B1B);
}
