import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import 'domain/task.dart';
import 'domain/task_status.dart';
import 'presentation/task_detail_screen.dart';
import 'utils/task_month_grouper.dart';
import 'widgets/task_card.dart';
import 'widgets/task_status_tabs.dart';
import 'widgets/task_summary_strip.dart';
import 'widgets/tasks_filter_bar.dart';
import 'widgets/tasks_search_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  final _pageController = PageController();

  TaskStatus _selectedTab = TaskStatus.current;
  String _searchQuery = '';
  String? _projectFilter;
  String? _tagFilter;
  Map<TaskStatus, int> _counts = {
    for (final status in TaskStatus.values) status: 0,
  };
  List<String> _filterProjects = [];
  List<String> _filterTags = [];
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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    setState(() => _isLoading = true);
    if (!_servicesReady) {
      if (!mounted) return;
      setState(() {
        _counts = {for (final status in TaskStatus.values) status: 0};
        _filterProjects = [];
        _filterTags = [];
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
    final repo = AppServices.instance.tasks;
    _counts = repo.countByStatus();
    _filterProjects = repo.distinctProjects(status: _selectedTab);
    _filterTags = repo.distinctTags(status: _selectedTab);
    if (_projectFilter != null && !_filterProjects.contains(_projectFilter)) {
      _projectFilter = null;
    }
    if (_tagFilter != null && !_filterTags.contains(_tagFilter)) {
      _tagFilter = null;
    }
  }

  void _onTabSelected(TaskStatus status, {bool fromPageView = false}) {
    setState(() {
      _selectedTab = status;
      _projectFilter = null;
      _tagFilter = null;
      _loadTasks();
    });
    if (!fromPageView && _pageController.hasClients) {
      _pageController.animateToPage(
        status.tabIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    final status = TaskStatus.fromTabIndex(index);
    if (status == _selectedTab) return;
    _onTabSelected(status, fromPageView: true);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _loadTasks();
    });
  }

  void _onProjectFilterChanged(String? project) {
    setState(() => _projectFilter = project);
  }

  void _onTagFilterChanged(String? tag) {
    setState(() => _tagFilter = tag);
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
        TaskSummaryStrip(
          counts: _counts,
          onStatusTap: _onTabSelected,
        ),
        TaskStatusTabs(
          selected: _selectedTab,
          onSelected: _onTabSelected,
        ),
        TasksFilterBar(
          projects: _filterProjects,
          tags: _filterTags,
          selectedProject: _projectFilter,
          selectedTag: _tagFilter,
          onProjectChanged: _onProjectFilterChanged,
          onTagChanged: _onTagFilterChanged,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: TaskStatus.tabOrder.length,
                  itemBuilder: (context, index) {
                    return _buildTabBodyFor(TaskStatus.tabOrder[index]);
                  },
                ),
        ),
      ],
    );
  }

  List<Task> _tasksForStatus(TaskStatus status) {
    if (!_servicesReady) return [];
    return AppServices.instance.tasks.search(
      status: status,
      query: _searchQuery,
      projectFilter: _projectFilter,
      tagFilter: _tagFilter,
    );
  }

  Widget _buildTabBodyFor(TaskStatus status) {
    final tasks = _tasksForStatus(status);

    if (tasks.isEmpty) {
      return _EmptyTabMessage(
        status: status,
        hasSearch: _searchQuery.trim().isNotEmpty,
        hasFilter: _projectFilter != null || _tagFilter != null,
      );
    }

    if (status.isArchived) {
      return _buildArchivedList(tasks, status);
    }

    return RefreshIndicator(
      onRefresh: reload,
      color: TraceColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.marginMobile,
          0,
          TraceSpacing.marginMobile,
          TraceSpacing.xl,
        ),
        itemCount: tasks.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: TraceSpacing.sm),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _openTask(task),
          );
        },
      ),
    );
  }

  Widget _buildArchivedList(List<Task> tasks, TaskStatus status) {
    final groups = TaskMonthGrouper.group(tasks, status);

    return RefreshIndicator(
      onRefresh: reload,
      color: TraceColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.marginMobile,
          0,
          TraceSpacing.marginMobile,
          TraceSpacing.xl,
        ),
        itemCount: groups.length,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return Padding(
            padding: EdgeInsets.only(
              bottom: groupIndex == groups.length - 1 ? 0 : TraceSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: TraceSpacing.sm),
                  child: Text(
                    group.label,
                    style: TraceTypography.labelMMMono.copyWith(
                      color: TraceColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...group.tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: TraceSpacing.sm),
                    child: Opacity(
                      opacity: 0.92,
                      child: TaskCard(
                        task: task,
                        onTap: () => _openTask(task),
                      ),
                    ),
                  ),
                ),
              ],
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
    required this.hasFilter,
  });

  final TaskStatus status;
  final bool hasSearch;
  final bool hasFilter;

  String get _title {
    if (hasSearch || hasFilter) {
      return 'No matches in ${status.summaryLabel}';
    }
    return switch (status) {
      TaskStatus.current => 'No active tasks.',
      TaskStatus.upcoming => 'No upcoming tasks.',
      TaskStatus.completed => 'No completed tasks.',
      TaskStatus.failed => 'No failed tasks.',
    };
  }

  String get _subtitle {
    if (hasSearch) {
      return 'Try another query or clear the search field.';
    }
    if (hasFilter) {
      return 'Try another filter or reset to All.';
    }
    return 'Create a task to begin.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TraceSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: TraceColors.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: TraceSpacing.md),
            Text(
              _title,
              style: TraceTypography.headlineSm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraceSpacing.sm),
            Text(
              _subtitle,
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
