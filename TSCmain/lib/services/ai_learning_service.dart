import 'package:shared_preferences/shared_preferences.dart';

class AiLearningService {
  static Future<void> recordCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('preferred_category', category);
  }

  static Future<void> recordBudget(int budget) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_budget', budget);
  }

  static Future<String?> getPreferredCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_category');
  }

  static Future<int?> getLastBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_budget');
  }
}