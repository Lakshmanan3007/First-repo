import '../storage/onboarding_repository.dart';
import '../storage/hive_initializer.dart';
import '../../features/notifications/data/notification_preferences_repository.dart';
import '../../features/notifications/data/notification_state_store.dart';
import '../../features/notifications/services/notification_coordinator.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/tasks/data/task_repository.dart';

/// Application-wide services initialized at startup.
class AppServices {
  AppServices({
    required this.onboarding,
    required this.tasks,
    required this.notifications,
  });

  final OnboardingRepository onboarding;
  final TaskRepository tasks;
  final NotificationService notifications;

  static late final AppServices instance;

  static Future<void> initialize() async {
    await HiveInitializer.init();
    final onboarding = await OnboardingRepository.create();
    final tasks = await TaskRepository.open();
    final notificationPrefs = await NotificationPreferencesRepository.create();
    final notificationState = await NotificationStateStore.create();
    final notifications = NotificationService(
      preferences: notificationPrefs,
      state: notificationState,
      coordinator: NotificationCoordinator(notificationState),
    );
    instance = AppServices(
      onboarding: onboarding,
      tasks: tasks,
      notifications: notifications,
    );
  }
}
