import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../../features/tasks/domain/task_constants.dart';
import '../../features/tasks/domain/task_priority.dart';
import '../../shared/widgets/trace_app_bar.dart';
import '../../shared/widgets/trace_button.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime? _startTime;
  DateTime? _deadline;
  String _selectedProject = TaskConstants.defaultProject;
  TaskPriority _priority = TaskPriority.high;
  final List<String> _tags = ['ENGINEERING', 'URGENT'];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select date and time';
    return DateFormat('MMM d, y • HH:mm').format(dateTime);
  }

  Future<void> _pickDateTime({required bool deadline}) async {
    final now = DateTime.now();
    final initial = deadline ? (_deadline ?? now.add(const Duration(hours: 1))) : (_startTime ?? now);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (deadline) {
        _deadline = combined;
      } else {
        _startTime = combined;
      }
    });
  }

  void _setPriority(TaskPriority priority) {
    setState(() => _priority = priority);
  }

  void _addTag() {
    final raw = _tagsController.text.trim();
    if (raw.isEmpty) return;
    final normalized = raw.replaceAll('#', '').toUpperCase();
    if (normalized.isEmpty || _tags.contains(normalized)) {
      _tagsController.clear();
      return;
    }
    setState(() {
      _tags.add(normalized);
      _tagsController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _discardDraft() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      _startTime = null;
      _deadline = null;
      _selectedProject = TaskConstants.defaultProject;
      _priority = TaskPriority.high;
      _tags
        ..clear()
        ..addAll(['ENGINEERING', 'URGENT']);
    });
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deadline is required.')),
      );
      return;
    }
    if (_startTime != null && _startTime!.isAfter(_deadline!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be before deadline.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await AppServices.instance.tasks.create(
        name: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        deadline: _deadline!,
        project: _selectedProject,
        priority: _priority,
        tags: _tags,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully.')),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TraceAppBar(showBackButton: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TraceSpacing.marginMobile,
            TraceSpacing.lg,
            TraceSpacing.marginMobile,
            120,
          ),
          children: [
            Text(
              'PROCESS / TASK.05',
              style: TraceTypography.labelMMMono.copyWith(
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: TraceSpacing.xs),
            Text('New Task', style: TraceTypography.headlineMd),
            const SizedBox(height: TraceSpacing.lg),
            _SectionLabel('Task Identity'),
            const SizedBox(height: TraceSpacing.xs),
            TextFormField(
              controller: _nameController,
              style: TraceTypography.headlineSm,
              decoration: const InputDecoration(
                hintText: 'Task Name...',
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: TraceSpacing.md),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: TraceColors.outlineVariant),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: TraceColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: TraceSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Start Time (Opt)',
                    value: _formatDateTime(_startTime),
                    emphasized: false,
                    onTap: () => _pickDateTime(deadline: false),
                  ),
                ),
                const SizedBox(width: TraceSpacing.md),
                Expanded(
                  child: _DateTile(
                    label: 'Deadline (Req)*',
                    value: _formatDateTime(_deadline),
                    emphasized: true,
                    onTap: () => _pickDateTime(deadline: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TraceSpacing.lg),
            _SectionLabel('Description / Context'),
            const SizedBox(height: TraceSpacing.xs),
            TextFormField(
              controller: _descriptionController,
              minLines: 5,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: 'Type / to use templates or enter details...',
              ),
            ),
            const SizedBox(height: TraceSpacing.xs),
            Row(
              children: [
                const Icon(Icons.notes, size: 14, color: TraceColors.secondary),
                const SizedBox(width: TraceSpacing.xs),
                Text(
                  'MARKDOWN COMPATIBLE',
                  style: TraceTypography.labelSMono,
                ),
              ],
            ),
            const SizedBox(height: TraceSpacing.lg),
            _SectionLabel('Project'),
            const SizedBox(height: TraceSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedProject,
              items: TaskConstants.projects
                  .map(
                    (project) => DropdownMenuItem<String>(
                      value: project,
                      child: Text(project),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProject = value);
                }
              },
            ),
            const SizedBox(height: TraceSpacing.lg),
            _SectionLabel('Priority'),
            const SizedBox(height: TraceSpacing.xs),
            Row(
              children: TaskPriority.values.map((priority) {
                final selected = _priority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: TraceSpacing.xs),
                    child: OutlinedButton(
                      onPressed: () => _setPriority(priority),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            selected ? TraceColors.primary : Colors.transparent,
                        foregroundColor:
                            selected ? TraceColors.onPrimary : TraceColors.secondary,
                        side: BorderSide(
                          color: selected
                              ? TraceColors.primary
                              : TraceColors.outlineVariant,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: TraceSpacing.sm,
                        ),
                      ),
                      child: Text(
                        priority.label,
                        style: TraceTypography.labelMMMono.copyWith(
                          color: selected
                              ? TraceColors.onPrimary
                              : TraceColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: TraceSpacing.lg),
            _SectionLabel('Classification Tags'),
            const SizedBox(height: TraceSpacing.xs),
            Container(
              padding: const EdgeInsets.all(TraceSpacing.sm),
              decoration: BoxDecoration(
                color: TraceColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
                border: Border.all(
                  color: TraceColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Wrap(
                spacing: TraceSpacing.xs,
                runSpacing: TraceSpacing.xs,
                children: [
                  ..._tags.map(
                    (tag) => TraceTaskChip(
                      label: '#$tag',
                      textColor: TraceColors.primary,
                      backgroundColor: TraceColors.surfaceContainerLow,
                      borderColor: TraceColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TraceSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    style: TraceTypography.labelMMMono.copyWith(
                      color: TraceColors.primary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '+ ADD TAG',
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: TraceSpacing.sm),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add, color: TraceColors.primary),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: TraceSpacing.sm),
              Wrap(
                spacing: TraceSpacing.xs,
                runSpacing: TraceSpacing.xs,
                children: _tags
                    .map(
                      (tag) => ActionChip(
                        label: Text('#$tag'),
                        onPressed: () => _removeTag(tag),
                        avatar: const Icon(Icons.close, size: 14),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: TraceSpacing.xl),
            TraceButton(
              label: _isSaving ? 'Creating...' : 'Create Task',
              icon: Icons.arrow_right_alt,
              expand: true,
              onPressed: _isSaving ? null : _submit,
            ),
            const SizedBox(height: TraceSpacing.md),
            TraceButton(
              label: 'Discard Draft',
              variant: TraceButtonVariant.ghost,
              expand: true,
              onPressed: _isSaving ? null : _discardDraft,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TraceTypography.labelMMMono.copyWith(
        color: TraceColors.secondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.emphasized,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TraceTypography.labelMMMono.copyWith(
            color: emphasized ? TraceColors.primary : TraceColors.secondary,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: TraceSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TraceSpacing.sm),
            decoration: BoxDecoration(
              color: emphasized
                  ? TraceColors.surfaceContainerLowest
                  : TraceColors.surfaceContainerLow,
              border: Border.all(
                color: emphasized ? TraceColors.primary : TraceColors.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
            ),
            child: Text(
              value,
              style: TraceTypography.labelMMMono.copyWith(
                color: TraceColors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
