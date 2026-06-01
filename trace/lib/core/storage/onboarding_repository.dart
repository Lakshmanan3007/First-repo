import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has finished first-launch onboarding.
class OnboardingRepository {
  OnboardingRepository(this._prefs);

  static const _completedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  static Future<OnboardingRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingRepository(prefs);
  }

  bool get isCompleted => _prefs.getBool(_completedKey) ?? false;

  Future<void> markCompleted() async {
    await _prefs.setBool(_completedKey, true);
  }

  /// For development / settings reset in a later phase.
  Future<void> reset() async {
    await _prefs.remove(_completedKey);
  }
}
