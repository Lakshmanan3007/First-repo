import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../notifications/domain/notification_preferences.dart';
import '../notifications/presentation/notifications_preview_screen.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  NotificationPreferences _notificationPrefs =
      NotificationPreferences.defaults;
  bool _use24Hour = true;
  bool _isLoading = true;

  bool get _servicesReady {
    try {
      AppServices.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    if (!_servicesReady) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _notificationPrefs = AppServices.instance.notifications.preferences;
      _isLoading = false;
    });
  }

  Future<void> _saveNotificationPrefs(NotificationPreferences prefs) async {
    if (!_servicesReady) return;
    await AppServices.instance.notifications.savePreferences(prefs);
    setState(() => _notificationPrefs = prefs);
  }

  String get _timezoneLabel {
    final now = DateTime.now();
    final hours = now.timeZoneOffset.inHours;
    final sign = hours >= 0 ? '+' : '-';
    return 'UTC $sign${hours.abs().toString().padLeft(2, '0')}:00';
  }

  Future<void> _clearLocalCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local cache?'),
        content: const Text(
          'This removes all tasks and notification history stored on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !_servicesReady) return;

    await AppServices.instance.tasks.clearAll();
    await AppServices.instance.notifications.resetState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local cache cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        TraceSpacing.lg,
        TraceSpacing.marginMobile,
        TraceSpacing.xl,
      ),
      children: [
        Text('Settings', style: TraceTypography.headlineMd),
        const SizedBox(height: TraceSpacing.xs),
        Text(
          'Configure your operational environment.',
          style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
        ),
        const SizedBox(height: TraceSpacing.lg),
        SettingsSection(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          child: Padding(
            padding: const EdgeInsets.all(TraceSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Theme', style: TraceTypography.bodyMd),
                    Row(
                      children: [
                        _ThemeChip(label: 'LIGHT', selected: true),
                        const SizedBox(width: TraceSpacing.xs),
                        _ThemeChip(
                          label: 'DARK',
                          selected: false,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dark theme coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TraceSpacing.lg),
        SettingsSection(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          child: Padding(
            padding: const EdgeInsets.all(TraceSpacing.md),
            child: Column(
              children: [
                SettingsToggleRow(
                  title: 'Push Notifications',
                  subtitle: 'TASK REMINDERS + ALERTS',
                  value: _notificationPrefs.pushEnabled,
                  onChanged: (value) => _saveNotificationPrefs(
                    _notificationPrefs.copyWith(pushEnabled: value),
                  ),
                ),
                const Divider(height: TraceSpacing.lg),
                SettingsToggleRow(
                  title: 'Email Digests',
                  subtitle: 'WEEKLY PERFORMANCE OVERVIEW',
                  value: _notificationPrefs.emailDigests,
                  onChanged: (value) => _saveNotificationPrefs(
                    _notificationPrefs.copyWith(emailDigests: value),
                  ),
                ),
                const SizedBox(height: TraceSpacing.md),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsPreviewScreen(),
                      ),
                    );
                  },
                  child: const Text('PREVIEW ALERT STYLES'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TraceSpacing.lg),
        SettingsSection(
          icon: Icons.schedule_outlined,
          title: 'Time Settings',
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(TraceSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIMEZONE', style: TraceTypography.labelSMono),
                        const SizedBox(height: TraceSpacing.xs),
                        Text(_timezoneLabel, style: TraceTypography.bodyMd),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(TraceSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FORMAT', style: TraceTypography.labelSMono),
                            const SizedBox(height: TraceSpacing.xs),
                            Text(
                              _use24Hour ? '24-HOUR' : '12-HOUR',
                              style: TraceTypography.bodyMd,
                            ),
                          ],
                        ),
                        Switch(
                          value: _use24Hour,
                          onChanged: (value) =>
                              setState(() => _use24Hour = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TraceSpacing.lg),
        SettingsSection(
          icon: Icons.storage_outlined,
          title: 'Storage / Local Data',
          child: Padding(
            padding: const EdgeInsets.all(TraceSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOCAL CACHE USAGE',
                      style: TraceTypography.labelMMMono,
                    ),
                    Text(
                      _servicesReady
                          ? '${AppServices.instance.tasks.getAll().length} TASKS'
                          : '—',
                      style: TraceTypography.labelMMMono.copyWith(
                        color: TraceColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TraceSpacing.sm),
                const LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 4,
                  color: TraceColors.primary,
                  backgroundColor: TraceColors.surfaceContainer,
                ),
                const SizedBox(height: TraceSpacing.lg),
                OutlinedButton(
                  onPressed: _servicesReady ? _clearLocalCache : null,
                  child: const Text('CLEAR LOCAL CACHE'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TraceSpacing.lg),
        SettingsSection(
          icon: Icons.info_outline,
          title: 'About TRACE',
          child: Padding(
            padding: const EdgeInsets.all(TraceSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: TraceTypography.bodyMd),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TraceSpacing.sm,
                        vertical: TraceSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: TraceColors.surfaceContainer,
                        border: Border.all(color: TraceColors.surfaceContainer),
                      ),
                      child: Text(
                        'v1.0.0-REL',
                        style: TraceTypography.labelMMMono.copyWith(
                          color: TraceColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TraceColors.primary : TraceColors.surfaceContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.md,
            vertical: TraceSpacing.xs,
          ),
          child: Text(
            label,
            style: TraceTypography.labelMMMono.copyWith(
              color: selected ? TraceColors.onPrimary : TraceColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
