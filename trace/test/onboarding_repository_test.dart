import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/core/storage/onboarding_repository.dart';

void main() {
  test('onboarding starts incomplete and can be marked complete', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = await OnboardingRepository.create();

    expect(repo.isCompleted, isFalse);

    await repo.markCompleted();
    expect(repo.isCompleted, isTrue);

    await repo.reset();
    expect(repo.isCompleted, isFalse);
  });
}
