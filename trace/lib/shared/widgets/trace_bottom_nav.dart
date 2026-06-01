import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

enum TraceNavTab { tasks, plan, stats, sys }

class TraceBottomNav extends StatelessWidget {
  const TraceBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onCreatePressed,
  });

  final TraceNavTab currentTab;
  final ValueChanged<TraceNavTab> onTabSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: TraceColors.surfaceContainerHigh),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: TraceSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.view_list_outlined,
                    label: 'TASKS',
                    selected: currentTab == TraceNavTab.tasks,
                    onTap: () => onTabSelected(TraceNavTab.tasks),
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'PLAN',
                    selected: currentTab == TraceNavTab.plan,
                    onTap: () => onTabSelected(TraceNavTab.plan),
                  ),
                  const SizedBox(width: 72),
                  _NavItem(
                    icon: Icons.query_stats_outlined,
                    label: 'STATS',
                    selected: currentTab == TraceNavTab.stats,
                    onTap: () => onTabSelected(TraceNavTab.stats),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'SYS',
                    selected: currentTab == TraceNavTab.sys,
                    onTap: () => onTabSelected(TraceNavTab.sys),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              child: GestureDetector(
                onTap: onCreatePressed,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TraceColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: TraceColors.primary.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: TraceColors.onPrimary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? TraceColors.primary : TraceColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: TraceSpacing.xs),
            Text(
              label,
              style: TraceTypography.labelSMono.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
