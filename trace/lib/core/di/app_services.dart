import '../storage/hive_initializer.dart';

import '../../features/notifications/data/notification_preferences_repository.dart';

import '../../features/notifications/data/notification_state_store.dart';

import '../../features/notifications/services/notification_coordinator.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/settings/services/app_settings_service.dart';
import '../../features/tasks/data/task_repository.dart';
import '../../features/tasks/data/taxonomy_repository.dart';

/// Application-wide services initialized at startup.

class AppServices {
  AppServices({
    required this.tasks,
    required this.taxonomy,
    required this.notifications,
    required this.settings,
  });

  final TaskRepository tasks;
  final TaxonomyRepository taxonomy;
  final NotificationService notifications;
  final AppSettingsService settings;



  static late final AppServices instance;



  static Future<void> initialize() async {

    await HiveInitializer.init();

    final tasks = await TaskRepository.open();
    final taxonomy = await TaxonomyRepository.create();
    final notificationPrefs = await NotificationPreferencesRepository.create();
    final notificationState = await NotificationStateStore.create();
    final settings = await AppSettingsService.create();

    final notifications = NotificationService(
      preferences: notificationPrefs,
      state: notificationState,
      coordinator: NotificationCoordinator(notificationState),
    );

    instance = AppServices(
      tasks: tasks,
      taxonomy: taxonomy,
      notifications: notifications,
      settings: settings,
    );
  }

}


