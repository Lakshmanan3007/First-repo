import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';
import '../utils/activity_journal_builder.dart';

class ActivityJournalItem extends StatelessWidget {
  const ActivityJournalItem({
    super.key,
    required this.event,
    required this.isLast,
    this.onTap,
  });

  final ActivityEvent event;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? TraceSpacing.md : TraceSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Stack(
                children: [
                  if (!isLast)
                    Positioned(
                      top: 18,
                      bottom: 0,
                      left: 5.5,
                      child: Container(
                        width: 1,
                        color: TraceColors.surfaceContainerHighest,
                      ),
                    ),
                  Positioned(
                    top: 6,
                    left: 4.5,
                    child: _SpineDot(primary: event.isPrimary),
                  ),
                ],
              ),
            ),
            Expanded(child: _EventBody(event: event, onTap: onTap)),
          ],
        ),
      ),
    );
  }
}

class _SpineDot extends StatelessWidget {
  const _SpineDot({required this.primary});

  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: TraceColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: primary ? TraceColors.primary : TraceColors.outlineVariant,
          width: 2,
        ),
      ),
    );
  }
}

class _EventBody extends StatelessWidget {
  const _EventBody({required this.event, this.onTap});

  final ActivityEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (event.kind) {
      ActivityEventKind.daySummary => _DaySummaryCard(event: event, onTap: onTap),
      ActivityEventKind.batchCreated => _BatchCard(event: event),
      ActivityEventKind.deepWorkActive => _DeepWorkCard(event: event),
      _ => _StandardCard(event: event, onTap: onTap),
    };
  }
}

class _StandardCard extends StatelessWidget {
  const _StandardCard({required this.event, this.onTap});

  final ActivityEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(event.at);
    final muted = event.kind == ActivityEventKind.taskFailed;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TraceTypography.titleS.copyWith(
                    color: muted ? TraceColors.secondary : TraceColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(time, style: TraceTypography.labelSMono),
            ],
          ),
          if (event.body != null) ...[
            const SizedBox(height: TraceSpacing.xs),
            Container(
              padding: const EdgeInsets.fromLTRB(
                TraceSpacing.sm,
                TraceSpacing.xs,
                0,
                TraceSpacing.xs,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: TraceColors.surfaceContainer, width: 2),
                ),
              ),
              child: Text(
                event.body!,
                style: TraceTypography.bodyMd.copyWith(
                  color: TraceColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (event.tags.isNotEmpty) ...[
            const SizedBox(height: TraceSpacing.sm),
            Wrap(
              spacing: TraceSpacing.sm,
              runSpacing: TraceSpacing.xs,
              children: event.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TraceColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(TraceSpacing.radiusSm),
                        border: Border.all(color: TraceColors.outlineVariant),
                      ),
                      child: Text(
                        '#${tag.toLowerCase()}',
                        style: TraceTypography.labelSMono.copyWith(
                          fontSize: 10,
                          color: TraceColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(event.at);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                event.title,
                style: TraceTypography.labelMMMono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TraceColors.secondary,
                ),
              ),
            ),
            Text(
              time,
              style: TraceTypography.labelSMono.copyWith(
                color: TraceColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: TraceSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
            border: Border.all(color: TraceColors.surfaceContainerHigh),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < event.batchTaskNames.length; i++)
                Container(
                  color: TraceColors.surfaceContainerLowest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TraceSpacing.sm,
                    vertical: TraceSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_box_outline_blank,
                        size: 14,
                        color: TraceColors.outline,
                      ),
                      const SizedBox(width: TraceSpacing.sm),
                      Expanded(
                        child: Text(
                          event.batchTaskNames[i],
                          style: TraceTypography.labelMMMono.copyWith(
                            fontSize: 12,
                            color: TraceColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeepWorkCard extends StatelessWidget {
  const _DeepWorkCard({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(event.at);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                event.title,
                style: TraceTypography.titleS.copyWith(color: TraceColors.secondary),
              ),
            ),
            Text(
              time,
              style: TraceTypography.labelSMono.copyWith(color: TraceColors.outline),
            ),
          ],
        ),
        if (event.body != null) ...[
          const SizedBox(height: TraceSpacing.xs),
          Text(
            event.body!,
            style: TraceTypography.bodyMd.copyWith(
              color: TraceColors.secondary.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  const _DaySummaryCard({required this.event, this.onTap});

  final ActivityEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final segments = event.summarySegments ?? 0;
    final duration = event.summaryDuration ?? Duration.zero;
    final durationLabel = ActivityJournalBuilder.formatDurationLabel(duration);

    return Material(
      color: TraceColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
        child: Container(
          padding: const EdgeInsets.all(TraceSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
            border: Border.all(
              color: TraceColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TraceTypography.labelMMMono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TraceColors.primary,
                      ),
                    ),
                    const SizedBox(height: TraceSpacing.xs),
                    Text(
                      '$segments ACTIVE_SEGMENTS // $durationLabel TOTAL_TIME',
                      style: TraceTypography.labelSMono.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: TraceColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
