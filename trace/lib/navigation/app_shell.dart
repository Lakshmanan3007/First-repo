import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/create_task/create_task_screen.dart';
import '../../features/notifications/widgets/notification_overlay_host.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../shared/widgets/profile_sheet.dart';
import '../../shared/widgets/trace_app_bar.dart';
import '../../shared/widgets/trace_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  TraceNavTab _currentTab = TraceNavTab.tasks;
  final _tasksKey = GlobalKey<TasksScreenState>();
  final _scheduleKey = GlobalKey<ScheduleScreenState>();
  final _activityKey = GlobalKey<ActivityScreenState>();
  final _settingsKey = GlobalKey<SettingsScreenState>();
  final _notificationHostKey = GlobalKey<NotificationOverlayHostState>();

  late final List<Widget> _screens = <Widget>[
    TasksScreen(key: _tasksKey),
    ScheduleScreen(key: _scheduleKey),
    ActivityScreen(key: _activityKey),
    SettingsScreen(key: _settingsKey),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateNotifications();
    });
  }

  int get _tabIndex {
    return switch (_currentTab) {
      TraceNavTab.tasks => 0,
      TraceNavTab.plan => 1,
      TraceNavTab.stats => 2,
      TraceNavTab.sys => 3,
    };
  }

  Future<void> _evaluateNotifications() async {
    try {
      await AppServices.instance.tasks.syncLifecycleStatuses();
      final tasks = AppServices.instance.tasks.getAll();
      final alerts = await AppServices.instance.notifications.evaluateTasks(
        tasks,
      );
      _notificationHostKey.currentState?.showAlerts(alerts);
    } catch (_) {
      // AppServices not initialized (e.g. widget tests).
    }
  }

  void _onTabSelected(TraceNavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == TraceNavTab.plan) {
      _scheduleKey.currentState?.reload();
    } else if (tab == TraceNavTab.stats) {
      _activityKey.currentState?.reload();
    } else if (tab == TraceNavTab.sys) {
      _settingsKey.currentState?.reload();
    }
    _evaluateNotifications();
  }

  void _openSettings() {
    setState(() => _currentTab = TraceNavTab.sys);
    _settingsKey.currentState?.reload();
  }

  void _showProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ProfileSheet(onOpenSettings: _openSettings),
    );
  }

  Future<void> _onCreatePressed() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CreateTaskScreen()),
    );
    await _tasksKey.currentState?.reload();
    await _scheduleKey.currentState?.reload();
    await _activityKey.currentState?.reload();
    _settingsKey.currentState?.reload();
    await _evaluateNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraceAppBar(onProfilePressed: _showProfileSheet),
      body: NotificationOverlayHost(
        key: _notificationHostKey,
        child: IndexedStack(
          index: _tabIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: TraceBottomNav(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
        onCreatePressed: _onCreatePressed,
      ),
    );
  }
}
