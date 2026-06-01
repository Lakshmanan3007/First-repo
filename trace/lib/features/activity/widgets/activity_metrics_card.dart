import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';

class ActivityMetricsCard extends StatelessWidget {
  const ActivityMetricsCard({required this.metrics, super.key});

  final ActivityMetrics7d metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.md),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
        border: Border.all(color: TraceColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYS_METRICS_7D',
                style: TraceTypography.labelSMono.copyWith(
                  letterSpacing: 0.08 * 10,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: TraceColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: TraceSpacing.xs),
                  Text(
                    metrics.syncOk ? 'SYNC_OK' : 'SYNC_ERR',
                    style: TraceTypography.labelSMono.copyWith(
                      color: TraceColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: TraceSpacing.lg),
          Row(
            children: [
              _MetricColumn(
                label: 'Load',
                value: '${metrics.loadJobs}',
                unit: 'JOBS',
              ),
              _verticalRule(),
              _MetricColumn(
                label: 'Health',
                value: '${metrics.healthPercent}',
                unit: '%',
              ),
              _verticalRule(),
              _MetricColumn(
                label: 'Uptime',
                value: '${metrics.uptimeHours}',
                unit: 'H',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalRule() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: TraceSpacing.lg),
      color: TraceColors.surfaceContainerHigh,
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TraceTypography.labelSMono,
          ),
          const SizedBox(height: TraceSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TraceTypography.labelMMMono.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TraceColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TraceTypography.labelSMono.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
