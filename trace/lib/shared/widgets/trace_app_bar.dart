import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

class TraceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TraceAppBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.onProfilePressed,
    this.subtitle,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final String? subtitle;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TraceColors.background.withValues(alpha: 0.92),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TRACE',
                          style: TraceTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TraceTypography.labelMd.copyWith(
                              color: TraceColors.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (showBackButton) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TRACE',
                          style: TraceTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TraceTypography.labelMd.copyWith(
                              color: TraceColors.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onProfilePressed,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
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
