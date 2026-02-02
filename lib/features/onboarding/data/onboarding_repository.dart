import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  OnboardingRepository({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const _onboardingCompletedKey = 'onboarding_completed';

  bool get isOnboardingCompleted =>
      _prefs.getBool(_onboardingCompletedKey) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompletedKey, true);
  }
}
