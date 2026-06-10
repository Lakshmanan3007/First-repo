import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/trace_notification.dart';

class TraceNotificationBanner extends StatelessWidget {
  const TraceNotificationBanner({
    super.key,
    required this.notification,
    required this.onDismiss,
    this.onTap,
  });

  final TraceNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (notification.style) {
      TraceNotificationStyle.critical =>
        TraceColors.error.withValues(alpha: 0.1),
      _ => const Color(0xFFEEEEEE),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: TraceSpacing.md),
      child: Material(
        color: TraceColors.surfaceContainerLowest,
        elevation: 0,
        shadowColor: TraceColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(TraceSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: TraceColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _IconBadge(notification: notification),
                const SizedBox(width: TraceSpacing.md),
                Expanded(child: _Content(notification: notification)),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, color: TraceColors.secondary),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.notification});

  final TraceNotification notification;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (notification.style) {
      TraceNotificationStyle.critical => (
          TraceColors.error,
          TraceColors.onError,
          Icons.error,
        ),
      TraceNotificationStyle.warning => (
          TraceColors.surfaceContainerHigh,
          TraceColors.primary,
          Icons.calendar_today_outlined,
        ),
      TraceNotificationStyle.normal => (
          const Color(0xFF1B1B1B),
          TraceColors.onPrimary,
          Icons.assignment_outlined,
        ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: foreground, size: 20),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.notification});

  final TraceNotification notification;

  @override
  Widget build(BuildContext context) {
    final categoryColor = notification.style == TraceNotificationStyle.critical
        ? TraceColors.error
        : TraceColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.categoryLabel,
          style: TraceTypography.labelCaps.copyWith(color: categoryColor),
        ),
        const SizedBox(height: TraceSpacing.xs),
        if (notification.detail != null &&
            notification.type == TraceNotificationType.deadlineApproaching)
          RichText(
            text: TextSpan(
              style: TraceTypography.bodyMd,
              children: [
                TextSpan(text: notification.message),
                const TextSpan(
                  text: ' • ',
                  style: TextStyle(color: TraceColors.secondary),
                ),
                TextSpan(
                  text: notification.detail!,
                  style: TraceTypography.bodyMd.copyWith(
                    color: notification.style == TraceNotificationStyle.warning
                        ? TraceColors.error
                        : TraceColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Text(notification.message, style: TraceTypography.bodyMd),
          if (notification.detail != null) ...[
            const SizedBox(height: 2),
            Text(
              notification.detail!,
              style: TraceTypography.bodyMd.copyWith(
                color: TraceColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ],
    );
  }
}
