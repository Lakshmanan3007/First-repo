import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../tasks/domain/task.dart';
import '../tasks/presentation/task_detail_screen.dart';
import 'domain/schedule_day_plan.dart';
import 'utils/schedule_planner.dart';
import 'widgets/schedule_date_strip.dart';
import 'widgets/schedule_timeline.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = SchedulePlanner.dateOnly(DateTime.now());
  ScheduleDayPlan _plan = ScheduleDayPlan(
    timeSections: [],
    completed: [],
    failed: [],
    tomorrowPreview: [],
  );
  bool _isLoading = true;
  bool _tomorrowExpanded = false;

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
      setState(() {
        _plan = ScheduleDayPlan(
          timeSections: [],
          completed: [],
          failed: [],
          tomorrowPreview: [],
        );
        _isLoading = false;
      });
      return;
    }

    await AppServices.instance.tasks.syncLifecycleStatuses();
    if (!mounted) return;

    final tasks = AppServices.instance.tasks.getAll();
    setState(() {
      _plan = SchedulePlanner.build(
        tasks: tasks,
        selectedDay: _selectedDay,
      );
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = SchedulePlanner.dateOnly(day);
      _tomorrowExpanded = false;
    });
    reload();
  }

  Future<void> _openTask(Task task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskDetailScreen(taskId: task.id),
      ),
    );
    if (changed == true) {
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleDateStrip(
          selectedDay: _selectedDay,
          onDaySelected: _onDaySelected,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RefreshIndicator(
                  onRefresh: reload,
                  color: TraceColors.primary,
                  child: _buildTimeline(),
                ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    if (_plan.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TraceSpacing.xl),
        children: [
          const SizedBox(height: TraceSpacing.xl),
          Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: TraceColors.secondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: TraceSpacing.md),
          Text(
            'No tasks on this day',
            style: TraceTypography.headlineSm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TraceSpacing.sm),
          Text(
            'Tasks with start times or deadlines on this date appear on the timeline.',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        TraceSpacing.lg,
        TraceSpacing.marginMobile,
        TraceSpacing.xl,
      ),
      children: [
        ScheduleTimeline(
          plan: _plan,
          selectedDay: _selectedDay,
          onTaskTap: _openTask,
          tomorrowExpanded: _tomorrowExpanded,
          onTomorrowToggle: _plan.tomorrowPreview.isEmpty
              ? null
              : () => setState(() => _tomorrowExpanded = !_tomorrowExpanded),
        ),
      ],
    );
  }
}
