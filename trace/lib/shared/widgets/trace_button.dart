import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

enum TraceButtonVariant { primary, secondary, ghost }

class TraceButton extends StatelessWidget {
  const TraceButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TraceButtonVariant.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TraceButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (icon != null) ...[
          const SizedBox(width: TraceSpacing.md),
          Icon(icon, size: 20),
        ],
      ],
    );

    switch (variant) {
      case TraceButtonVariant.primary:
        return SizedBox(
          width: expand ? double.infinity : null,
          child: ElevatedButton(onPressed: onPressed, child: child),
        );
      case TraceButtonVariant.secondary:
        return SizedBox(
          width: expand ? double.infinity : null,
          child: OutlinedButton(onPressed: onPressed, child: child),
        );
      case TraceButtonVariant.ghost:
        return TextButton(onPressed: onPressed, child: child);
    }
  }
}

class TraceTaskChip extends StatelessWidget {
  const TraceTaskChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: TraceSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor ?? TraceColors.surfaceContainer,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        border: Border.all(
          color: borderColor ?? TraceColors.outlineVariant,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label.toUpperCase(),
        style: TraceTypography.labelSMono.copyWith(
          color: textColor ?? TraceColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
