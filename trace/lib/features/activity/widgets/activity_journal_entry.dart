import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';

class ActivityJournalEntry extends StatelessWidget {
  const ActivityJournalEntry({
    super.key,
    required this.event,
    this.onTap,
  });

  final ActivityEvent event;
  final VoidCallback? onTap;

  static final _timeFormat = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TraceSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  event.iconGlyph,
                  style: TraceTypography.titleS,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: TraceSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(event.label, style: TraceTypography.labelMMMono),
                        const Spacer(),
                        Text(
                          _timeFormat.format(event.at),
                          style: TraceTypography.labelSMono.copyWith(
                            color: TraceColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(event.title, style: TraceTypography.bodyMd),
                    if (event.body != null && event.body!.trim().isNotEmpty) ...[
                      const SizedBox(height: TraceSpacing.xs),
                      Text(
                        event.body!,
                        style: TraceTypography.bodyMd.copyWith(
                          color: TraceColors.secondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
