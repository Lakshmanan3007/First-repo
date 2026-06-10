import 'package:shared_preferences/shared_preferences.dart';

import '../domain/task.dart';
import '../domain/task_constants.dart';

/// Persists custom projects and aggregates known tags from tasks.
class TaxonomyRepository {
  TaxonomyRepository(this._prefs);

  static const _customProjectsKey = 'trace_custom_projects';

  final SharedPreferences _prefs;

  static Future<TaxonomyRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TaxonomyRepository(prefs);
  }

  List<String> allProjects({List<Task> tasks = const []}) {
    final custom = _prefs.getStringList(_customProjectsKey) ?? [];
    final merged = <String>{
      ...TaskConstants.defaultProjects,
      ...custom,
      ...tasks.map((task) => task.project),
    };
    return merged.toList()..sort();
  }

  Future<void> addProject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final existing = allProjects();
    if (existing.any((p) => p.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    final custom = <String>{
      ...(_prefs.getStringList(_customProjectsKey) ?? []),
      trimmed,
    }.toList();
    await _prefs.setStringList(_customProjectsKey, custom);
  }

  List<String> allTags({List<Task> tasks = const []}) {
    final merged = <String>{};
    for (final task in tasks) {
      merged.addAll(task.tags);
    }
    return merged.toList()..sort();
  }
}
