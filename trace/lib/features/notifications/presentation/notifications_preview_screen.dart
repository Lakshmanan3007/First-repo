import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/trace_notification.dart';
import '../widgets/trace_notification_banner.dart';

/// Static preview of operational alert styles from UI/notification_concepts.
class NotificationsPreviewScreen extends StatefulWidget {
  const NotificationsPreviewScreen({super.key});

  @override
  State<NotificationsPreviewScreen> createState() =>
      _NotificationsPreviewScreenState();
}

class _NotificationsPreviewScreenState extends State<NotificationsPreviewScreen> {
  late List<TraceNotification> _samples;

  @override
  void initState() {
    super.initState();
    _samples = _buildSamples();
  }

  List<TraceNotification> _buildSamples() {
    return const [
      TraceNotification(
        id: 'sample_active',
        type: TraceNotificationType.taskActive,
        categoryLabel: 'SYSTEM ALERT',
        message: 'Task is now active.',
        style: TraceNotificationStyle.normal,
        icon: TraceNotificationIcon.assignment,
      ),
      TraceNotification(
        id: 'sample_deadline',
        type: TraceNotificationType.deadlineApproaching,
        categoryLabel: 'TEMPORAL UPDATE',
        message: 'Deadline approaching',
        detail: '10 minutes remaining.',
        style: TraceNotificationStyle.warning,
        icon: TraceNotificationIcon.calendar,
      ),
      TraceNotification(
        id: 'sample_failed',
        type: TraceNotificationType.taskFailed,
        categoryLabel: 'TERMINATION',
        message: 'Task moved to Failed.',
        style: TraceNotificationStyle.critical,
        icon: TraceNotificationIcon.error,
      ),
    ];
  }

  void _dismiss(String id) {
    setState(() => _samples.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraceColors.background,
      appBar: AppBar(
        backgroundColor: TraceColors.background,
        elevation: 0,
        title: Text('Alert Preview', style: TraceTypography.headlineSm),
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Padding(
                padding: const EdgeInsets.all(TraceSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      color: TraceColors.outlineVariant,
                    ),
                    const SizedBox(height: TraceSpacing.lg),
                    Container(
                      height: 96,
                      width: double.infinity,
                      color: TraceColors.surfaceContainer,
                    ),
                    const SizedBox(height: TraceSpacing.md),
                    Container(
                      height: 96,
                      width: double.infinity,
                      color: TraceColors.surfaceContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(TraceSpacing.containerPadding),
            children: [
              const SizedBox(height: TraceSpacing.xl),
              ..._samples.map(
                (notification) => TraceNotificationBanner(
                  notification: notification,
                  onDismiss: () => _dismiss(notification.id),
                ),
              ),
              const SizedBox(height: TraceSpacing.xl),
              Text(
                'CENTER FOR OPERATIONAL ALERTS',
                style: TraceTypography.labelMd.copyWith(
                  letterSpacing: 0.12 * 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TraceSpacing.sm),
              Text(
                'Live alerts appear automatically when tasks change state or approach deadlines.',
                style: TraceTypography.bodyMd.copyWith(
                  color: TraceColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
