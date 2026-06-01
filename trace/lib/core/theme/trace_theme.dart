import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'trace_colors.dart';
import 'trace_spacing.dart';
import 'trace_typography.dart';

abstract final class TraceTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TraceColors.background,
      colorScheme: const ColorScheme.light(
        primary: TraceColors.primary,
        onPrimary: TraceColors.onPrimary,
        secondary: TraceColors.secondary,
        onSecondary: TraceColors.onPrimary,
        surface: TraceColors.surface,
        onSurface: TraceColors.onSurface,
        error: TraceColors.error,
        onError: TraceColors.onError,
        outline: TraceColors.outline,
        outlineVariant: TraceColors.outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TraceColors.background,
        foregroundColor: TraceColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerColor: TraceColors.surfaceContainerHigh,
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        displayLarge: TraceTypography.displayLg,
        headlineMedium: TraceTypography.headlineMd,
        headlineSmall: TraceTypography.headlineSm,
        titleMedium: TraceTypography.titleS,
        bodyLarge: TraceTypography.bodyLg,
        bodyMedium: TraceTypography.bodyMd,
        labelMedium: TraceTypography.labelMd,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TraceColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TraceSpacing.md,
          vertical: TraceSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: TraceColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: TraceColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: TraceColors.primary, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TraceColors.primary,
          foregroundColor: TraceColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.lg,
            vertical: TraceSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
          ),
          textStyle: TraceTypography.titleS.copyWith(color: TraceColors.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TraceColors.primary,
          side: const BorderSide(color: TraceColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.lg,
            vertical: TraceSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
          ),
          textStyle: TraceTypography.labelMMMono,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TraceColors.primary,
          textStyle: TraceTypography.bodyMd.copyWith(color: TraceColors.primary),
        ),
      ),
    );
  }
}
