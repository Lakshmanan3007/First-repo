import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class TasksFilterBar extends StatelessWidget {
  const TasksFilterBar({
    super.key,
    required this.projects,
    required this.tags,
    required this.selectedProject,
    required this.selectedTag,
    required this.onProjectChanged,
    required this.onTagChanged,
  });

  final List<String> projects;
  final List<String> tags;
  final String? selectedProject;
  final String? selectedTag;
  final ValueChanged<String?> onProjectChanged;
  final ValueChanged<String?> onTagChanged;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty && tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        0,
        TraceSpacing.marginMobile,
        TraceSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (projects.isNotEmpty) ...[
            _FilterRow(
              icon: Icons.folder_outlined,
              children: [
                _FilterChip(
                  label: 'All projects',
                  selected: selectedProject == null,
                  onTap: () => onProjectChanged(null),
                ),
                ...projects.map(
                  (project) => _FilterChip(
                    label: project,
                    selected: selectedProject == project,
                    onTap: () => onProjectChanged(project),
                  ),
                ),
              ],
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: TraceSpacing.xs),
            _FilterRow(
              icon: Icons.sell_outlined,
              children: [
                _FilterChip(
                  label: 'All tags',
                  selected: selectedTag == null,
                  onTap: () => onTagChanged(null),
                ),
                ...tags.map(
                  (tag) => _FilterChip(
                    label: '#$tag',
                    selected: selectedTag == tag,
                    onTap: () => onTagChanged(tag),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.icon, required this.children});

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TraceColors.secondary.withValues(alpha: 0.8)),
        const SizedBox(width: TraceSpacing.sm),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: TraceSpacing.xs),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? TraceColors.primary
          : TraceColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.md,
            vertical: TraceSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
            border: Border.all(
              color: selected
                  ? TraceColors.primary
                  : TraceColors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            label,
            style: TraceTypography.labelMMMono.copyWith(
              fontSize: 11,
              color: selected ? TraceColors.onPrimary : TraceColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
