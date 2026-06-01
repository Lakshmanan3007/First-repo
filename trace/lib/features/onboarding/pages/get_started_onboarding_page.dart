import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class GetStartedOnboardingPage extends StatelessWidget {
  const GetStartedOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.gutter,
        TraceSpacing.xl,
        TraceSpacing.gutter,
        140,
      ),
      children: [
        Center(
          child: Text(
            'STEP 03 — 03',
            style: TraceTypography.labelMMMono.copyWith(
              letterSpacing: 4,
              color: TraceColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: TraceSpacing.lg),
        Text(
          'Velocity meets clarity.',
          style: TraceTypography.displayLg.copyWith(fontSize: 36, height: 44 / 36),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TraceSpacing.md),
        Text(
          'Creating your first trace is instantaneous. No fluff, just operational focus.',
          style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TraceSpacing.xl),
        _QuickEntryPreview(),
        const SizedBox(height: TraceSpacing.lg),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: TraceColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt,
                color: TraceColors.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: TraceSpacing.md),
            Expanded(
              child: Text(
                'Designed for speed. Optimized for results.',
                style: TraceTypography.labelMMMono.copyWith(
                  color: TraceColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickEntryPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.lg),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
        border: Border.all(color: TraceColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: TraceColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK ENTRY',
                style: TraceTypography.labelMMMono.copyWith(
                  color: TraceColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: TraceColors.primary,
                ),
              ),
              Icon(Icons.auto_awesome, size: 20, color: TraceColors.secondary),
            ],
          ),
          const SizedBox(height: TraceSpacing.xl),
          Text(
            'ACTION ITEM',
            style: TraceTypography.labelSMono.copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: TraceSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: TraceSpacing.sm),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TraceColors.outlineVariant),
              ),
            ),
            child: Text(
              'Finalize Q4 Strategy Deck',
              style: TraceTypography.titleS.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: TraceSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'DUE DATE',
                  icon: Icons.calendar_today_outlined,
                  value: 'Today, 5:00 PM',
                ),
              ),
              const SizedBox(width: TraceSpacing.md),
              Expanded(
                child: _MetaTile(
                  label: 'PRIORITY',
                  showDot: true,
                  value: 'High Orbit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.md),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TraceTypography.labelSMono),
          const SizedBox(height: TraceSpacing.xs),
          Row(
            children: [
              if (showDot) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: TraceColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: TraceSpacing.xs),
              ],
              if (icon != null) ...[
                Icon(icon, size: 14, color: TraceColors.primary),
                const SizedBox(width: TraceSpacing.xs),
              ],
              Expanded(
                child: Text(
                  value,
                  style: TraceTypography.labelMMMono.copyWith(
                    color: TraceColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
