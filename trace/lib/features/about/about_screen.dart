import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../../shared/widgets/trace_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TraceAppBar(showBackButton: true, subtitle: 'About TRACE'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.marginMobile,
          TraceSpacing.lg,
          TraceSpacing.marginMobile,
          TraceSpacing.xl,
        ),
        children: [
          Text('TRACE', style: TraceTypography.displayLg),
          const SizedBox(height: TraceSpacing.xs),
          Text(AppInfo.versionLabel, style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.md),
          Text(
            AppInfo.tagline,
            style: TraceTypography.bodyLg.copyWith(color: TraceColors.secondary),
          ),
          const SizedBox(height: TraceSpacing.xl),
          Text(
            'TRACE is a time-aware accountability system designed to help users manage commitments through structured task lifecycles and preserved history.',
            style: TraceTypography.bodyMd,
          ),
          const SizedBox(height: TraceSpacing.lg),
          Text('Built around:', style: TraceTypography.labelMMMono),
          const SizedBox(height: TraceSpacing.xs),
          Text(
            'Upcoming → Current → Completed / Failed',
            style: TraceTypography.bodyMd,
          ),
          const SizedBox(height: TraceSpacing.lg),
          Text(
            'Every task leaves a permanent record, creating a clear timeline of commitments, progress, and outcomes.',
            style: TraceTypography.bodyMd,
          ),
          const SizedBox(height: TraceSpacing.xl),
          _InfoRow(label: 'Developer', value: 'A.D. LAKSHMANAN'),
          const SizedBox(height: TraceSpacing.sm),
          _InfoRow(
            label: 'Email',
            value: 'lakshmanan8.092006@gmail.com',
          ),
          const SizedBox(height: TraceSpacing.sm),
          _InfoRow(
            label: 'GitHub',
            value: 'https://github.com/Lakshmanan3007',
          ),
          const SizedBox(height: TraceSpacing.sm),
          _InfoRow(
            label: 'Portfolio',
            value: 'https://lakshmanan-dev.lovable.app/',
          ),
          const SizedBox(height: TraceSpacing.xl),
          Text('Privacy', style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.xs),
          Text(
            'TRACE stores all data locally on your device. No account is required. No personal information is collected.',
            style: TraceTypography.bodyMd,
          ),
          const SizedBox(height: TraceSpacing.xl),
          Text('Open Source Licenses', style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.xs),
          Text(
            'Use Flutter\'s generated license screen.',
            style: TraceTypography.bodyMd,
          ),
          const SizedBox(height: TraceSpacing.xl),
          Text('Copyright', style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.xs),
          Text('© 2026 A.D. LAKSHMANAN', style: TraceTypography.bodyMd),
          const SizedBox(height: TraceSpacing.xl),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const LicensePage(
                    applicationName: 'TRACE',
                  ),
                ),
              );
            },
            child: const Text('Open Source Licenses'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TraceTypography.labelSMono.copyWith(color: TraceColors.secondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TraceTypography.bodyMd,
          ),
        ),
      ],
    );
  }
}
