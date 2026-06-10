import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        border: Border.all(
          color: TraceColors.surfaceContainer.withValues(alpha: 0.9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(TraceSpacing.md),
            decoration: const BoxDecoration(
              color: TraceColors.surface,
              border: Border(
                bottom: BorderSide(color: TraceColors.surfaceContainer),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: TraceColors.primary),
                const SizedBox(width: TraceSpacing.sm),
                Text(title, style: TraceTypography.titleS),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TraceTypography.bodyMd),
              const SizedBox(height: TraceSpacing.xs),
              Text(
                subtitle,
                style: TraceTypography.labelSMono,
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: TraceColors.onPrimary,
          activeTrackColor: TraceColors.primary,
        ),
      ],
    );
  }
}
