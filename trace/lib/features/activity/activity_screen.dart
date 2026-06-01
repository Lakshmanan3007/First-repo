import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../tasks/presentation/task_detail_screen.dart';
import 'domain/activity_event.dart';
import 'utils/activity_journal_builder.dart';
import 'widgets/activity_day_section.dart';
import 'widgets/activity_metrics_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen> {
  ActivityJournal _journal = const ActivityJournal(
    sessionId: '0x0000',
    versionLabel: 'v1.0.0_STABLE',
    metrics: ActivityMetrics7d(
      loadJobs: 0,
      healthPercent: 100,
      uptimeHours: 0,
      syncOk: true,
    ),
    dayGroups: [],
  );
  bool _isLoading = true;

  bool get _servicesReady {
    try {
      AppServices.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() => _isLoading = true);
    if (!_servicesReady) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    await AppServices.instance.tasks.syncLifecycleStatuses();
    if (!mounted) return;

    final tasks = AppServices.instance.tasks.getAll();
    setState(() {
      _journal = ActivityJournalBuilder.build(tasks: tasks);
      _isLoading = false;
    });
  }

  Future<void> _openEvent(ActivityEvent event) async {
    final taskId = event.taskId;
    if (taskId == null) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskDetailScreen(taskId: taskId),
      ),
    );
    if (changed == true) {
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return RefreshIndicator(
      onRefresh: reload,
      color: TraceColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.containerPadding,
          TraceSpacing.lg,
          TraceSpacing.containerPadding,
          TraceSpacing.xl,
        ),
        children: [
          _OperationalHeader(
            sessionId: _journal.sessionId,
            versionLabel: _journal.versionLabel,
          ),
          const SizedBox(height: TraceSpacing.lg),
          ActivityMetricsCard(metrics: _journal.metrics),
          const SizedBox(height: TraceSpacing.xl),
          if (_journal.isEmpty)
            _EmptyJournal()
          else
            ..._journal.dayGroups.map((group) {
              return ActivityDaySection(
                group: group,
                muted: !group.isToday,
                onEventTap: _openEvent,
              );
            }),
        ],
      ),
    );
  }
}

class _OperationalHeader extends StatelessWidget {
  const _OperationalHeader({
    required this.sessionId,
    required this.versionLabel,
  });

  final String sessionId;
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: TraceSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TraceColors.primary)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MEM_SESSION // $sessionId',
            style: TraceTypography.labelMMMono.copyWith(
              letterSpacing: 0.12 * 12,
            ),
          ),
          const SizedBox(height: TraceSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Operational Log', style: TraceTypography.headlineMd),
              const Spacer(),
              Text(
                versionLabel,
                style: TraceTypography.labelSMono.copyWith(
                  color: TraceColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraceSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.history_edu_outlined,
            size: 40,
            color: TraceColors.secondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: TraceSpacing.md),
          Text('No journal entries yet', style: TraceTypography.headlineSm),
          const SizedBox(height: TraceSpacing.sm),
          Text(
            'Create and complete tasks to build your operational memory log.',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
