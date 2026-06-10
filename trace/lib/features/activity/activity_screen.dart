import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../tasks/presentation/task_detail_screen.dart';
import 'domain/activity_event.dart';
import 'utils/activity_journal_builder.dart';
import 'widgets/activity_summary_card.dart';
import 'widgets/activity_timeline_section.dart';
import 'widgets/activity_transitions_section.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen> {
  ActivityJournal _journal = const ActivityJournal(
    summary: ActivityTodaySummary(
      currentCount: 0,
      completedToday: 0,
      failedToday: 0,
      upcomingToday: 0,
    ),
    timeline: [],
    upcomingTransitions: [],
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

  Future<void> _openTask(String taskId) async {
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
          Text('Activity', style: TraceTypography.headlineMd),
          const SizedBox(height: TraceSpacing.xs),
          Text(
            'What happened, what is happening, and what comes next.',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
          ),
          const SizedBox(height: TraceSpacing.lg),
          ActivitySummaryCard(summary: _journal.summary),
          const SizedBox(height: TraceSpacing.lg),
          ActivityTransitionsSection(
            transitions: _journal.upcomingTransitions,
            onTap: (transition) => _openTask(transition.taskId),
          ),
          if (_journal.isEmpty)
            _EmptyJournal()
          else
            ..._journal.timeline.map(
              (period) => ActivityTimelineSection(
                period: period,
                onEventTap: (event) {
                  final taskId = event.taskId;
                  if (taskId != null) _openTask(taskId);
                },
              ),
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
            color: TraceColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: TraceSpacing.md),
          Text('No activity yet', style: TraceTypography.headlineSm),
          const SizedBox(height: TraceSpacing.sm),
          Text(
            'Create and complete tasks to build your operational journal.',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
