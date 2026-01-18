

import '../models/product.dart';
import '../models/user_profile.dart';

/// Rule-Based Intelligent Recommendation Engine
/// MCA Minor Project – Explainable AI Component
class RecommendationEngine {
  /// Filters products strictly under budget
  /// and aligned with learned user preferences.
  static List<Product> recommend({
    required List<Product> allProducts,
    required UserProfile profile,
    required int budget,
  }) {
    return allProducts.where((product) {
      // RULE 1: HARD BUDGET CONSTRAINT
      if (product.price > budget) return false;

      // RULE 2: LEARNED BUDGET BEHAVIOR
      if (profile.dominantBudget == "under_1500" &&
          product.price > 1500) {
        return false;
      }

      // RULE 3: INTENT-BASED FILTERING (GIFTS)
      if (profile.dominantIntent == "gift") {
        final name = product.name.toLowerCase();
        return name.contains('candle') ||
            name.contains('plush') ||
            name.contains('key') ||
            name.contains('gift');
      }

      // DEFAULT: ALLOW
      return true;
    }).toList();
  }

  /// Explainable AI message shown in chat/UI
  static String explanation(UserProfile profile, int budget) {
    return "Picked for you based on your style 💗 "
        "${profile.dominantIntent} shopper · "
        "${profile.dominantVibe} vibe · "
        "under ₹$budget.";
  }
}