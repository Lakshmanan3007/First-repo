import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import 'domain/task.dart';
import 'domain/task_status.dart';
import 'presentation/task_detail_screen.dart';
import 'widgets/task_card.dart';
import 'widgets/task_status_tabs.dart';
import 'widgets/tasks_search_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  TaskStatus _selectedTab = TaskStatus.current;
  String _searchQuery = '';
  List<Task> _tasks = [];
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    setState(() => _isLoading = true);
    if (!_servicesReady) {
      if (!mounted) return;
      setState(() {
        _tasks = [];
        _isLoading = false;
      });
      return;
    }
    await AppServices.instance.tasks.syncLifecycleStatuses();
    if (!mounted) return;
    _loadTasks();
    setState(() => _isLoading = false);
  }

  void _loadTasks() {
    _tasks = AppServices.instance.tasks.search(
      status: _selectedTab,
      query: _searchQuery,
    );
  }

  void _onTabSelected(TaskStatus status) {
    setState(() {
      _selectedTab = status;
      _loadTasks();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _loadTasks();
    });
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
        TasksSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        TaskStatusTabs(
          selected: _selectedTab,
          onSelected: _onTabSelected,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_tasks.isEmpty) {
      return _EmptyTabMessage(
        status: _selectedTab,
        hasSearch: _searchQuery.trim().isNotEmpty,
      );
    }

    return RefreshIndicator(
      onRefresh: reload,
      color: TraceColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.marginMobile,
          0,
          TraceSpacing.marginMobile,
          TraceSpacing.xl,
        ),
        itemCount: _tasks.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: TraceSpacing.sm),
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Opacity(
            opacity: task.isArchived ? 0.88 : 1,
            child: TaskCard(
              task: task,
              onTap: () => _openTask(task),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyTabMessage extends StatelessWidget {
  const _EmptyTabMessage({
    required this.status,
    required this.hasSearch,
  });

  final TaskStatus status;
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final title = hasSearch
        ? 'No matches in ${status.label}'
        : 'No ${status.label.toLowerCase()} tasks';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TraceSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: TraceColors.secondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: TraceSpacing.md),
            Text(title, style: TraceTypography.headlineSm, textAlign: TextAlign.center),
            const SizedBox(height: TraceSpacing.sm),
            Text(
              hasSearch
                  ? 'Try another query or clear the search field.'
                  : 'Create a task with the + button to begin tracing work.',
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
