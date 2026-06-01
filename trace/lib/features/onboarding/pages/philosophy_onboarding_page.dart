import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class PhilosophyOnboardingPage extends StatelessWidget {
  const PhilosophyOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.containerPadding,
        TraceSpacing.xl,
        TraceSpacing.containerPadding,
        120,
      ),
      children: [
        SizedBox(
          height: 220,
          child: Center(child: _TaskFlowIllustration()),
        ),
        const SizedBox(height: TraceSpacing.xl),
        Text(
          'Every Task Leaves a Trace.',
          style: TraceTypography.headlineMd,
        ),
        const SizedBox(height: TraceSpacing.md),
        Text(
          'Tasks move through permanent states. Your progress is recorded in an immutable ledger of productivity.',
          style: TraceTypography.bodyLg.copyWith(color: TraceColors.secondary),
        ),
        const SizedBox(height: TraceSpacing.xl),
        _FeatureCard(
          icon: Icons.history,
          title: 'Immutable History',
          body:
              'Every action is timestamped and secured for personal accountability audits.',
        ),
        const SizedBox(height: TraceSpacing.md),
        _FeatureCard(
          icon: Icons.account_tree_outlined,
          title: 'State Transitions',
          body:
              'Clear demarcation between planned work, active focus, and completed outputs.',
        ),
      ],
    );
  }
}

class _TaskFlowIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 36,
          child: Container(
            height: 1,
            color: TraceColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FlowNode(
              icon: Icons.assignment_outlined,
              label: 'UPCOMING',
              emphasized: false,
            ),
            Icon(Icons.arrow_forward, color: TraceColors.outlineVariant, size: 20),
            _FlowNode(
              icon: Icons.play_arrow,
              label: 'CURRENT',
              emphasized: true,
            ),
            Icon(Icons.arrow_forward, color: TraceColors.outlineVariant, size: 20),
            _FlowNode(
              icon: Icons.task_alt_outlined,
              label: 'FINAL',
              emphasized: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.icon,
    required this.label,
    required this.emphasized,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final size = emphasized ? 56.0 : 48.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: emphasized ? TraceColors.primary : TraceColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
            border: emphasized
                ? null
                : Border.all(color: TraceColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: TraceColors.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: emphasized ? TraceColors.onPrimary : TraceColors.secondary,
            size: emphasized ? 28 : 22,
          ),
        ),
        const SizedBox(height: TraceSpacing.xs),
        Text(
          label,
          style: TraceTypography.labelCaps.copyWith(
            fontSize: 10,
            letterSpacing: 1.2,
            color: emphasized ? TraceColors.primary : TraceColors.secondary,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.lg),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        border: Border.all(
          color: TraceColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: TraceColors.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TraceColors.primary, size: 24),
          const SizedBox(width: TraceSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TraceTypography.headlineSm),
                const SizedBox(height: TraceSpacing.unit),
                Text(
                  body,
                  style: TraceTypography.bodyMd.copyWith(
                    color: TraceColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
