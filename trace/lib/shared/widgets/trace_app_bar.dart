import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

class TraceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TraceAppBar({
    super.key,
    this.showBackButton = false,
    this.onMenuPressed,
    this.onBackPressed,
  });

  final bool showBackButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TraceColors.background.withValues(alpha: 0.8),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: TraceColors.surfaceContainerHigh),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TraceSpacing.marginMobile,
              vertical: TraceSpacing.sm,
            ),
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    onPressed: onBackPressed ?? () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: TraceColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  )
                else
                  IconButton(
                    onPressed: onMenuPressed,
                    icon: const Icon(Icons.menu, color: TraceColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                if (!showBackButton) const SizedBox(width: TraceSpacing.sm),
                Text(
                  'TRACE',
                  style: TraceTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TraceColors.surfaceContainerHighest,
                    border: Border.all(color: TraceColors.outlineVariant),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: TraceColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
