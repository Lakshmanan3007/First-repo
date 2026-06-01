import 'package:hive_flutter/hive_flutter.dart';

import '../../features/tasks/data/task_hive_adapter.dart';

abstract final class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
  }
}
