import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../tasks/domain/create_task_draft.dart';
import '../tasks/domain/task_constants.dart';
import '../tasks/domain/task_priority.dart';
import '../../shared/widgets/trace_app_bar.dart';
import '../../shared/widgets/trace_button.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key, this.draft});

  final CreateTaskDraft? draft;

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _newProjectController = TextEditingController();

  DateTime? _startTime;
  DateTime? _deadline;
  late String _selectedProject;
  late TaskPriority _priority;
  final List<String> _tags = [];
  List<String> _projects = TaskConstants.defaultProjects;
  List<String> _knownTags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    if (draft != null) {
      _nameController.text = draft.name ?? '';
      _descriptionController.text = draft.description ?? '';
      _selectedProject = draft.project ?? TaskConstants.defaultProject;
      _priority = draft.priority ?? TaskPriority.medium;
      _tags.addAll(draft.tags);
    } else {
      _selectedProject = TaskConstants.defaultProject;
      _priority = TaskPriority.medium;
    }
    _loadTaxonomy();
  }

  void _loadTaxonomy() {
    try {
      final tasks = AppServices.instance.tasks.getAll();
      setState(() {
        _projects = AppServices.instance.taxonomy.allProjects(tasks: tasks);
        _knownTags = AppServices.instance.taxonomy.allTags(tasks: tasks);
        if (!_projects.contains(_selectedProject)) {
          _projects = [..._projects, _selectedProject]..sort();
        }
      });
    } catch (_) {
      _projects = TaskConstants.defaultProjects;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _newProjectController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select date and time';
    return DateFormat('MMM d, y • HH:mm').format(dateTime);
  }

  Future<void> _pickDateTime({required bool deadline}) async {
    final now = DateTime.now();
    final initial = deadline
        ? (_deadline ?? now.add(const Duration(hours: 1)))
        : (_startTime ?? now);
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

  Future<void> _createProject() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        _newProjectController.clear();
        return AlertDialog(
          title: const Text('Create New Project'),
          content: TextField(
            controller: _newProjectController,
            decoration: const InputDecoration(
              hintText: 'Project name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _newProjectController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    await AppServices.instance.taxonomy.addProject(name);
    _loadTaxonomy();
    setState(() => _selectedProject = name);
  }

  void _setPriority(TaskPriority priority) {
    setState(() => _priority = priority);
  }

  void _addTag([String? rawTag]) {
    final raw = (rawTag ?? _tagsController.text).trim();
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
      _priority = TaskPriority.medium;
      _tags.clear();
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
      appBar: const TraceAppBar(showBackButton: true, subtitle: 'New Task'),
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
            TextFormField(
              controller: _nameController,
              style: TraceTypography.headlineSm,
              decoration: const InputDecoration(
                hintText: 'Task name',
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
                    label: 'Start Time',
                    value: _formatDateTime(_startTime),
                    onTap: () => _pickDateTime(deadline: false),
                  ),
                ),
                const SizedBox(width: TraceSpacing.md),
                Expanded(
                  child: _DateTile(
                    label: 'Deadline *',
                    value: _formatDateTime(_deadline),
                    onTap: () => _pickDateTime(deadline: true),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: TraceSpacing.xs),
              child: Text(
                'Optional • Starts now if empty',
                style: TraceTypography.labelSMono.copyWith(
                  color: TraceColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: TraceSpacing.lg),
            TextFormField(
              controller: _descriptionController,
              minLines: 5,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: 'Add details, notes, or context...',
              ),
            ),
            const SizedBox(height: TraceSpacing.lg),
            Text(
              'Project',
              style: TraceTypography.labelMMMono.copyWith(
                color: TraceColors.secondary,
              ),
            ),
            const SizedBox(height: TraceSpacing.xs),
            DropdownButtonFormField<String>(
              key: ValueKey('project-$_selectedProject-${_projects.length}'),
              initialValue: _projects.contains(_selectedProject)
                  ? _selectedProject
                  : _projects.first,
              items: _projects
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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _createProject,
                child: const Text('Create New Project'),
              ),
            ),
            const SizedBox(height: TraceSpacing.lg),
            Text(
              'Priority',
              style: TraceTypography.labelMMMono.copyWith(
                color: TraceColors.secondary,
              ),
            ),
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
                        foregroundColor: selected
                            ? TraceColors.onPrimary
                            : TraceColors.secondary,
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
            Text(
              'Tags',
              style: TraceTypography.labelMMMono.copyWith(
                color: TraceColors.secondary,
              ),
            ),
            const SizedBox(height: TraceSpacing.xs),
            if (_knownTags.isNotEmpty) ...[
              Wrap(
                spacing: TraceSpacing.xs,
                runSpacing: TraceSpacing.xs,
                children: _knownTags
                    .where((tag) => !_tags.contains(tag))
                    .map(
                      (tag) => ActionChip(
                        label: Text('#$tag'),
                        onPressed: () => _addTag(tag),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: TraceSpacing.sm),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'Add tag',
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: TraceSpacing.sm),
                IconButton(
                  onPressed: () => _addTag(),
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
                      (tag) => InputChip(
                        label: Text('#$tag'),
                        onDeleted: () => _removeTag(tag),
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

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TraceTypography.labelMMMono.copyWith(
            color: TraceColors.primary,
            fontWeight: FontWeight.w600,
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
              color: TraceColors.surfaceContainerLowest,
              border: Border.all(color: TraceColors.outlineVariant),
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
