import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class TasksSearchBar extends StatelessWidget {
  const TasksSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TraceSpacing.marginMobile,
        vertical: TraceSpacing.md,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TraceTypography.labelMMMono.copyWith(
          fontSize: 13,
          color: TraceColors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'SEARCH_DATABASE...',
          hintStyle: TraceTypography.labelMMMono.copyWith(
            fontSize: 13,
            color: TraceColors.secondary,
          ),
          filled: true,
          fillColor: TraceColors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.md,
            vertical: TraceSpacing.sm,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: TraceColors.secondary,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
            borderSide: BorderSide(
              color: TraceColors.outlineVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
