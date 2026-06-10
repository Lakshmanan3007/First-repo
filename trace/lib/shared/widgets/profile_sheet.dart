import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    super.key,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TraceSpacing.marginMobile,
          TraceSpacing.md,
          TraceSpacing.marginMobile,
          TraceSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Profile', style: TraceTypography.headlineSm),
            const SizedBox(height: TraceSpacing.xs),
            Text(
              'Local profile for this device. Cloud sync arrives in a future release.',
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            ),
            const SizedBox(height: TraceSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              subtitle: const Text('Theme, notifications, data'),
              onTap: () {
                Navigator.pop(context);
                onOpenSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
