import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static const _myIncomeKey = 'my_income';
  static const _targetIncomeKey = 'target_income';
  static const _targetIncomeNameKey = 'target_income_name';
  static const _migrationKey = 'data_migrated_to_yen';
  static const _onboardingCompletedKey = 'onboarding_completed';

  static Future<double> getMyIncome() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateDataIfNeeded();
    return prefs.getDouble(_myIncomeKey) ?? 0;
  }

  static Future<double> getTargetIncome() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateDataIfNeeded();
    return prefs.getDouble(_targetIncomeKey) ?? 0;
  }

  static Future<String> getTargetIncomeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_targetIncomeNameKey) ?? '';
  }

  static Future<void> saveSettings({
    required double myIncome,
    required double targetIncome,
    required String targetIncomeName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_myIncomeKey, myIncome);
    await prefs.setDouble(_targetIncomeKey, targetIncome);
    await prefs.setString(_targetIncomeNameKey, targetIncomeName);
    await prefs.setBool(_migrationKey, true);
  }

  // 既存の万円単位データを円単位に変換
  static Future<void> _migrateDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final isMigrated = prefs.getBool(_migrationKey) ?? false;

    if (!isMigrated) {
      final myIncome = prefs.getDouble(_myIncomeKey);
      final targetIncome = prefs.getDouble(_targetIncomeKey);

      if (myIncome != null && myIncome > 0) {
        // 万円単位から円単位に変換
        await prefs.setDouble(_myIncomeKey, myIncome);
      }

      if (targetIncome != null && targetIncome > 0) {
        // 万円単位から円単位に変換
        await prefs.setDouble(_targetIncomeKey, targetIncome);
      }

      await prefs.setBool(_migrationKey, true);
    }
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }
}
