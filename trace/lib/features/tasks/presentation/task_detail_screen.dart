import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_services.dart';
import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../../../shared/widgets/trace_app_bar.dart';
import '../../../shared/widgets/trace_button.dart';
import '../../create_task/create_task_screen.dart';
import '../domain/create_task_draft.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';
import '../utils/task_display_format.dart';
import '../widgets/task_outcome_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;
  bool _isLoading = true;
  bool _isMutating = false;

  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _stampFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await AppServices.instance.tasks.syncLifecycleStatuses();
    final task = AppServices.instance.tasks.getById(widget.taskId);
    if (!mounted) return;
    setState(() {
      _task = task;
      _isLoading = false;
    });
  }

  Future<void> _completeTask() async {
    final note = await showTaskOutcomeDialog(
      context,
      title: 'Complete task?',
      message: 'This will archive the task as completed.',
      confirmLabel: 'Complete',
      defaultNote: 'Task completed successfully.',
    );
    if (note == null || !mounted) return;

    setState(() => _isMutating = true);
    try {
      await AppServices.instance.tasks.markCompleted(
        widget.taskId,
        note: note,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _failTask() async {
    final note = await showTaskOutcomeDialog(
      context,
      title: 'Mark task as failed?',
      message: 'This will move the task to the failed archive.',
      confirmLabel: 'Mark Failed',
      defaultNote: 'Unable to complete this task.',
    );
    if (note == null || !mounted) return;

    setState(() => _isMutating = true);
    try {
      await AppServices.instance.tasks.markFailed(
        widget.taskId,
        note: note,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _reattemptTask() async {
    final task = _task;
    if (task == null) return;

    setState(() => _isMutating = true);
    try {
      final draft = CreateTaskDraft(
        name: task.name,
        description: task.description,
        project: task.project,
        priority: task.priority,
        tags: task.tags,
      );

      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CreateTaskScreen(draft: draft),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TraceAppBar(showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _task == null
              ? _NotFoundBody(onBack: () => Navigator.pop(context))
              : _buildContent(_task!),
    );
  }

  Widget _buildContent(Task task) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.containerPadding,
        TraceSpacing.lg,
        TraceSpacing.containerPadding,
        120,
      ),
      children: [
        _ArchiveHeader(task: task),
        const SizedBox(height: TraceSpacing.xl),
        _MetadataArchive(task: task, dateFormat: _dateFormat),
        const SizedBox(height: TraceSpacing.xl),
        _ExecutionNotes(task: task),
        const SizedBox(height: TraceSpacing.xl),
        _TaxonomySection(tags: task.tags),
        const SizedBox(height: TraceSpacing.xl),
        _FinalStateCard(
          task: task,
          stampFormat: _stampFormat,
          isMutating: _isMutating,
          onComplete: _completeTask,
          onFail: _failTask,
          onReattempt: _reattemptTask,
        ),
      ],
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 40, color: TraceColors.secondary),
          const SizedBox(height: TraceSpacing.md),
          Text('Task record not found', style: TraceTypography.headlineSm),
          const SizedBox(height: TraceSpacing.md),
          TraceButton(label: 'Go Back', onPressed: onBack),
        ],
      ),
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 2, color: TraceColors.primary),
            const SizedBox(width: TraceSpacing.xs),
            Text(
              'ENTRY #${task.entryId}',
              style: TraceTypography.labelSMono.copyWith(
                color: TraceColors.primary,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (task.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TraceSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: TraceColors.surfaceContainer,
                  border: Border.all(color: TraceColors.outlineVariant),
                ),
                child: Text(
                  'IMMUTABLE RECORD',
                  style: TraceTypography.labelSMono.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: TraceSpacing.md),
        Text(
          task.name,
          style: TraceTypography.displayLg.copyWith(fontSize: 30, height: 1.1),
        ),
        const SizedBox(height: TraceSpacing.md),
        Wrap(
          spacing: TraceSpacing.xs,
          runSpacing: TraceSpacing.xs,
          children: [
            _StatusChip(
              label: TaskDisplayFormat.projectTag(task),
              outlined: true,
            ),
            _StatusChip(
              label: task.priority.dashboardLabel,
              filled: true,
            ),
            _StatusChip(
              label: task.status.label,
              muted: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetadataArchive extends StatelessWidget {
  const _MetadataArchive({
    required this.task,
    required this.dateFormat,
  });

  final Task task;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        border: Border.all(color: TraceColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(TraceSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TraceSpacing.md,
              vertical: TraceSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: TraceColors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: TraceColors.outlineVariant)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_edu, size: 16, color: TraceColors.primary),
                const SizedBox(width: TraceSpacing.sm),
                Text(
                  'METADATA ARCHIVE',
                  style: TraceTypography.labelSMono.copyWith(
                    color: TraceColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  'CHECKSUM VERIFIED',
                  style: TraceTypography.labelSMono.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
          _MetadataGrid(
            cells: [
              _MetaCell('PROJECT ID', TaskDisplayFormat.projectTag(task)),
              _MetaCell('REGISTRATION', dateFormat.format(task.createdAt)),
              _MetaCell(
                'EXECUTION START',
                task.startTime != null
                    ? dateFormat.format(task.startTime!)
                    : 'NOT SCHEDULED',
              ),
              _MetaCell(
                'EXECUTION END',
                task.completedAt != null
                    ? dateFormat.format(task.completedAt!)
                    : dateFormat.format(task.deadline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaCell {
  const _MetaCell(this.label, this.value);

  final String label;
  final String value;
}

class _MetadataGrid extends StatelessWidget {
  const _MetadataGrid({required this.cells});

  final List<_MetaCell> cells;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetaTile(cell: cells[0], showRightBorder: true, showBottomBorder: true)),
            Expanded(child: _MetaTile(cell: cells[1], showBottomBorder: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _MetaTile(cell: cells[2], showRightBorder: true)),
            Expanded(child: _MetaTile(cell: cells[3])),
          ],
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.cell,
    this.showRightBorder = false,
    this.showBottomBorder = false,
  });

  final _MetaCell cell;
  final bool showRightBorder;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          right: showRightBorder
              ? const BorderSide(color: TraceColors.outlineVariant)
              : BorderSide.none,
          bottom: showBottomBorder
              ? const BorderSide(color: TraceColors.outlineVariant)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cell.label,
            style: TraceTypography.labelSMono.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TraceSpacing.xs),
          Text(
            cell.value,
            style: TraceTypography.labelMMMono.copyWith(
              color: TraceColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutionNotes extends StatelessWidget {
  const _ExecutionNotes({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final description = task.description?.trim();
    final outcome = task.outcomeNote?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.terminal, size: 18, color: TraceColors.primary),
            const SizedBox(width: TraceSpacing.sm),
            Text(
              'EXECUTION LOGS & NOTES',
              style: TraceTypography.labelMMMono.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: TraceColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TraceSpacing.md),
        Container(
          padding: const EdgeInsets.only(left: TraceSpacing.lg),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: TraceColors.outlineVariant, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description?.isNotEmpty == true
                    ? description!
                    : 'No execution notes were recorded for this task.',
                style: TraceTypography.bodyMd.copyWith(
                  color: description?.isNotEmpty == true
                      ? TraceColors.onSurface
                      : TraceColors.secondary,
                  height: 1.5,
                ),
              ),
              if (outcome != null && outcome.isNotEmpty) ...[
                const SizedBox(height: TraceSpacing.md),
                Text(
                  task.status == TaskStatus.completed
                      ? 'COMPLETION NOTE'
                      : 'FAILURE NOTE',
                  style: TraceTypography.labelSMono.copyWith(
                    color: TraceColors.secondary,
                  ),
                ),
                const SizedBox(height: TraceSpacing.xs),
                Text(
                  outcome,
                  style: TraceTypography.bodyMd.copyWith(height: 1.5),
                ),
              ],
              if (description?.isNotEmpty == true) ...[
                const SizedBox(height: TraceSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TraceSpacing.md),
                  decoration: BoxDecoration(
                    color: TraceColors.surfaceContainerLowest,
                    border: const Border(
                      left: BorderSide(color: TraceColors.primary, width: 4),
                      top: BorderSide(color: TraceColors.outlineVariant),
                      right: BorderSide(color: TraceColors.outlineVariant),
                      bottom: BorderSide(color: TraceColors.outlineVariant),
                    ),
                  ),
                  child: Text(
                    'Operational context captured at time of execution.',
                    style: TraceTypography.labelMMMono.copyWith(
                      fontStyle: FontStyle.italic,
                      color: TraceColors.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxonomySection extends StatelessWidget {
  const _TaxonomySection({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAXONOMY CLASSIFICATION',
          style: TraceTypography.labelSMono.copyWith(letterSpacing: 2),
        ),
        const SizedBox(height: TraceSpacing.md),
        if (tags.isEmpty)
          Text(
            'No classification tags assigned.',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
          )
        else
          Wrap(
            spacing: TraceSpacing.sm,
            runSpacing: TraceSpacing.sm,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TraceSpacing.sm,
                      vertical: TraceSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: TraceColors.outlineVariant),
                    ),
                    child: Text(
                      tag,
                      style: TraceTypography.labelSMono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TraceColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _FinalStateCard extends StatelessWidget {
  const _FinalStateCard({
    required this.task,
    required this.stampFormat,
    required this.isMutating,
    required this.onComplete,
    required this.onFail,
    required this.onReattempt,
  });

  final Task task;
  final DateFormat stampFormat;
  final bool isMutating;
  final VoidCallback onComplete;
  final VoidCallback onFail;
  final VoidCallback onReattempt;

  @override
  Widget build(BuildContext context) {
    final stampDate = task.completedAt ?? task.failedAt ?? task.createdAt;

    return Container(
      padding: const EdgeInsets.all(TraceSpacing.lg),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainer,
        border: Border.all(color: TraceColors.primary.withValues(alpha: 0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: TraceColors.primary, size: 20),
              const SizedBox(width: TraceSpacing.md),
              Expanded(
                child: Text(
                  task.status == TaskStatus.completed
                      ? 'IMMUTABLE ARCHIVE RECORD'
                      : task.status == TaskStatus.failed
                          ? 'FAILED RECORD'
                          : 'ACTIVE OPERATIONAL RECORD',
                  style: TraceTypography.labelMMMono.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TraceColors.primary,
                  ),
                ),
              ),
              Text(
                'STAMP: ${stampFormat.format(stampDate).toUpperCase()}',
                style: TraceTypography.labelSMono.copyWith(
                  color: TraceColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TraceSpacing.lg),
          if (task.status == TaskStatus.current || task.status == TaskStatus.upcoming) ...[
            TraceButton(
              label: isMutating ? 'Processing...' : 'Mark Completed',
              expand: true,
              onPressed: isMutating ? null : onComplete,
            ),
            const SizedBox(height: TraceSpacing.sm),
            TraceButton(
              label: 'Mark Failed',
              variant: TraceButtonVariant.secondary,
              expand: true,
              onPressed: isMutating ? null : onFail,
            ),
          ] else if (task.status == TaskStatus.failed) ...[
            OutlinedButton(
              onPressed: isMutating ? null : onReattempt,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: TraceSpacing.md),
                side: const BorderSide(color: TraceColors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay, color: TraceColors.primary),
                  const SizedBox(width: TraceSpacing.sm),
                  Text(
                    'REATTEMPT FAILED TASK',
                    style: TraceTypography.labelMMMono.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TraceSpacing.sm),
            Text(
              'Requires operational clearance to reopen failed work.',
              style: TraceTypography.labelSMono.copyWith(
                fontSize: 9,
                color: TraceColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ] else
            Text(
              'This completed record is locked and cannot be modified.',
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.outlined = false,
    this.filled = false,
    this.muted = false,
  });

  final String label;
  final bool outlined;
  final bool filled;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? TraceColors.primary
            : muted
                ? TraceColors.surfaceContainerHighest
                : Colors.transparent,
        border: outlined || muted
            ? Border.all(color: TraceColors.outlineVariant)
            : null,
      ),
      child: Text(
        label,
        style: TraceTypography.labelSMono.copyWith(
          color: filled ? TraceColors.onPrimary : TraceColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
