import 'package:flutter/material.dart';

import '../../tasks/presentation/task_detail_screen.dart';
import '../../../core/di/app_services.dart';
import '../domain/trace_notification.dart';
import 'trace_notification_banner.dart';

class NotificationOverlayHost extends StatefulWidget {
  const NotificationOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationOverlayHost> createState() =>
      NotificationOverlayHostState();
}

class NotificationOverlayHostState extends State<NotificationOverlayHost> {
  final List<TraceNotification> _visible = [];

  void showAlerts(List<TraceNotification> alerts) {
    if (alerts.isEmpty) return;
    setState(() {
      final existingIds = _visible.map((n) => n.id).toSet();
      for (final alert in alerts) {
        if (!existingIds.contains(alert.id)) {
          _visible.add(alert);
        }
      }
      if (_visible.length > 3) {
        _visible.removeRange(0, _visible.length - 3);
      }
    });
  }

  Future<void> _dismiss(TraceNotification notification) async {
    if (_servicesReady) {
      await AppServices.instance.notifications.dismiss(notification.id);
    }
    if (!mounted) return;
    setState(() => _visible.removeWhere((n) => n.id == notification.id));
  }

  Future<void> _openTask(TraceNotification notification) async {
    final taskId = notification.taskId;
    if (taskId == null) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskDetailScreen(taskId: taskId),
      ),
    );
    await _dismiss(notification);
  }

  bool get _servicesReady {
    try {
      AppServices.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible.isNotEmpty)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _visible
                      .map(
                        (notification) => TraceNotificationBanner(
                          notification: notification,
                          onDismiss: () => _dismiss(notification),
                          onTap: notification.taskId != null
                              ? () => _openTask(notification)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
