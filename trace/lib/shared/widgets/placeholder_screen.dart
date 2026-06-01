import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TraceSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: TraceColors.secondary),
            const SizedBox(height: TraceSpacing.lg),
            Text(
              title,
              style: TraceTypography.headlineMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraceSpacing.sm),
            Text(
              subtitle,
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
