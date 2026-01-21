import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_memory.dart';

class MemoryService {
  // Keys for SharedPreferences
  static const _intentKey = 'memory_intent';
  static const _relationshipKey = 'memory_relationship';
  static const _occasionKey = 'memory_occasion';
  static const _vibeKey = 'memory_vibe';
  static const _budgetKey = 'memory_budget';
  static const _stageKey = 'memory_stage';

  /// Load user memory from local storage
  static Future<UserMemory> load() async {
    final prefs = await SharedPreferences.getInstance();

    return UserMemory(
      intent: prefs.getString(_intentKey),
      relationship: prefs.getString(_relationshipKey),
      occasion: prefs.getString(_occasionKey),
      vibe: prefs.getString(_vibeKey),
      budget: prefs.getString(_budgetKey),
      stage: prefs.getString(_stageKey) ?? 'greeting',
    );
  }

  /// Save full user memory to local storage
  static Future<void> save(UserMemory memory) async {
    final prefs = await SharedPreferences.getInstance();

    if (memory.intent != null) {
      prefs.setString(_intentKey, memory.intent!);
    }
    if (memory.relationship != null) {
      prefs.setString(_relationshipKey, memory.relationship!);
    }
    if (memory.occasion != null) {
      prefs.setString(_occasionKey, memory.occasion!);
    }
    if (memory.vibe != null) {
      prefs.setString(_vibeKey, memory.vibe!);
    }
    if (memory.budget != null) {
      prefs.setString(_budgetKey, memory.budget!);
    }

    prefs.setString(_stageKey, memory.stage);
  }

  /// Clear all stored memory (used when chat is reset)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_intentKey);
    await prefs.remove(_relationshipKey);
    await prefs.remove(_occasionKey);
    await prefs.remove(_vibeKey);
    await prefs.remove(_budgetKey);
    await prefs.remove(_stageKey);
  }
  /// Normalize relationship to match product category keys.
  /// This allows relationships like boyfriend/girlfriend to
  /// work seamlessly with categories such as boy_friend and girl_friend.
  static String? normalizeRelationshipToCategory(String? relationship) {
    if (relationship == null) return null;

    final r = relationship.toLowerCase();
    if (r.contains('boyfriend')) return 'boy_friend';
    if (r.contains('girlfriend')) return 'girl_friend';

    return relationship;
  }
}