import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class NavigationOnboardingPage extends StatelessWidget {
  const NavigationOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.gutter,
        TraceSpacing.xl,
        TraceSpacing.gutter,
        120,
      ),
      children: [
        Text(
          'NAVIGATION GUIDE',
          style: TraceTypography.labelSMono.copyWith(
            letterSpacing: 3,
            color: TraceColors.secondary,
          ),
        ),
        const SizedBox(height: TraceSpacing.xs),
        Text('Instruments of Precision', style: TraceTypography.headlineMd),
        const SizedBox(height: TraceSpacing.md),
        RichText(
          text: TextSpan(
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            children: [
              const TextSpan(
                text:
                    'Your workflow is organized into four distinct modules designed for absolute clarity. ',
              ),
              TextSpan(
                text: 'Every task leaves a trace.',
                style: TraceTypography.bodyMd.copyWith(
                  color: TraceColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TraceSpacing.xl),
        const _BentoModuleCard(
          index: '01',
          icon: Icons.assignment_outlined,
          iconBackground: TraceColors.primary,
          iconColor: TraceColors.onPrimary,
          title: 'Tasks',
          description:
              'Unified strategic imperatives. Organize by priority and execution phase.',
          largeIcon: true,
        ),
        const SizedBox(height: TraceSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: _BentoModuleCard(
                index: '02',
                icon: Icons.calendar_today_outlined,
                title: 'Schedule',
                description: 'Temporal planning and deep-work blocks.',
              ),
            ),
            SizedBox(width: TraceSpacing.md),
            Expanded(
              child: _BentoModuleCard(
                index: '03',
                icon: Icons.analytics_outlined,
                title: 'Activity',
                description: 'Data-driven performance insights.',
              ),
            ),
          ],
        ),
        const SizedBox(height: TraceSpacing.md),
        const _BentoModuleCard(
          index: '04',
          icon: Icons.settings_outlined,
          title: 'Preferences',
          description:
              'Calibrate the environment to your specific operational needs.',
          horizontal: true,
        ),
      ],
    );
  }
}

class _BentoModuleCard extends StatelessWidget {
  const _BentoModuleCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    this.horizontal = false,
    this.largeIcon = false,
    this.iconBackground = TraceColors.surfaceContainerHigh,
    this.iconColor = TraceColors.primary,
  });

  final String index;
  final IconData icon;
  final String title;
  final String description;
  final bool horizontal;
  final bool largeIcon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final iconSize = largeIcon ? 48.0 : 40.0;
    final iconWidget = Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconBackground,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
      ),
      child: Icon(icon, color: iconColor, size: largeIcon ? 24 : 22),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TraceSpacing.lg),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
        border: Border.all(color: TraceColors.surfaceContainerHigh),
      ),
      child: horizontal
          ? Row(
              children: [
                iconWidget,
                const SizedBox(width: TraceSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TraceTypography.titleS),
                      const SizedBox(height: TraceSpacing.xs),
                      Text(
                        description,
                        style: TraceTypography.labelMMMono.copyWith(
                          color: TraceColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconWidget,
                    Text(index, style: TraceTypography.labelSMono),
                  ],
                ),
                const SizedBox(height: TraceSpacing.md),
                Text(title, style: TraceTypography.titleS),
                const SizedBox(height: TraceSpacing.xs),
                Text(
                  description,
                  style: TraceTypography.labelMMMono.copyWith(
                    color: TraceColors.secondary,
                  ),
                ),
              ],
            ),
    );
  }
}
