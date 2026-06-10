import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../about/about_screen.dart';
import '../notifications/domain/notification_preferences.dart';
import '../notifications/presentation/notifications_preview_screen.dart';
import 'domain/app_settings.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  NotificationPreferences _notificationPrefs =
      NotificationPreferences.defaults;
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

  Future<void> _clearLocalCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Application Data?'),
        content: const Text(
          'This removes all tasks, notifications, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TraceColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !_servicesReady) return;

    await AppServices.instance.tasks.clearAll();
    await AppServices.instance.notifications.resetState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application data reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return ValueListenableBuilder(
      valueListenable: AppServices.instance.settings,
      builder: (context, settings, child) {
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
                            _ThemeChip(
                              label: 'LIGHT',
                              selected: settings.themeMode == AppThemeMode.light,
                              onTap: () =>
                                  AppServices.instance.settings
                                      .updateThemeMode(AppThemeMode.light),
                            ),
                            const SizedBox(width: TraceSpacing.xs),
                            _ThemeChip(
                              label: 'DARK',
                              selected: settings.themeMode == AppThemeMode.dark,
                              onTap: () =>
                                  AppServices.instance.settings
                                      .updateThemeMode(AppThemeMode.dark),
                            ),
                            const SizedBox(width: TraceSpacing.xs),
                            _ThemeChip(
                              label: 'AUTO',
                              selected: settings.themeMode == AppThemeMode.system,
                              onTap: () =>
                                  AppServices.instance.settings
                                      .updateThemeMode(AppThemeMode.system),
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
              icon: Icons.schedule_outlined,
              title: 'Time Format',
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
                          settings.use24Hour ? '24-HOUR' : '12-HOUR',
                          style: TraceTypography.bodyMd,
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.use24Hour,
                      onChanged: (value) =>
                          AppServices.instance.settings.updateUse24Hour(value),
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
              icon: Icons.storage_outlined,
              title: 'Data Management',
              child: Padding(
                padding: const EdgeInsets.all(TraceSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TASKS STORED',
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
                    const SizedBox(height: TraceSpacing.lg),
                    OutlinedButton(
                      onPressed: _servicesReady ? _clearLocalCache : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TraceColors.error,
                        side: const BorderSide(color: TraceColors.error),
                      ),
                      child: const Text('RESET APPLICATION DATA'),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                      child: const Text('VIEW ABOUT & LICENSE'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
