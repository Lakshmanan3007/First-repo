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
      splashFactory: InkSparkle.splashFactory,
      highlightColor: TraceColors.primary.withValues(alpha: 0.04),
      hoverColor: TraceColors.primary.withValues(alpha: 0.02),
      cardTheme: CardThemeData(
        color: TraceColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
          side: BorderSide(
            color: TraceColors.surfaceContainerHigh.withValues(alpha: 0.9),
          ),
        ),
      ),
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
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
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

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.dark(
        primary: TraceColors.primary,
        onPrimary: const Color(0xFFFAFAFA),
        secondary: const Color(0xFF9C9D9D),
        onSecondary: const Color(0xFFFAFAFA),
        surface: const Color(0xFF141414),
        onSurface: const Color(0xFFE8E8E8),
        error: TraceColors.error,
        onError: const Color(0xFFFAFAFA),
        outline: const Color(0xFF3A3A3A),
        outlineVariant: const Color(0xFF2A2A2A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: TraceColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: const Color(0xFF2A2A2A),
      splashFactory: InkSparkle.splashFactory,
      highlightColor: TraceColors.primary.withValues(alpha: 0.08),
      hoverColor: TraceColors.primary.withValues(alpha: 0.04),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
          side: const BorderSide(
            color: Color(0xFF2A2A2A),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TraceTypography.displayLg.copyWith(color: const Color(0xFFE8E8E8)),
        headlineMedium: TraceTypography.headlineMd.copyWith(color: const Color(0xFFE8E8E8)),
        headlineSmall: TraceTypography.headlineSm.copyWith(color: const Color(0xFFE8E8E8)),
        titleMedium: TraceTypography.titleS.copyWith(color: const Color(0xFFE8E8E8)),
        bodyLarge: TraceTypography.bodyLg.copyWith(color: const Color(0xFFDDDDDD)),
        bodyMedium: TraceTypography.bodyMd.copyWith(color: const Color(0xFFDDDDDD)),
        labelMedium: TraceTypography.labelMd.copyWith(color: const Color(0xFF9C9D9D)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TraceSpacing.md,
          vertical: TraceSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          borderSide: const BorderSide(color: TraceColors.primary, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TraceColors.primary,
          foregroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.lg,
            vertical: TraceSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
          ),
          textStyle: TraceTypography.titleS.copyWith(color: const Color(0xFFFAFAFA)),
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
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
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
