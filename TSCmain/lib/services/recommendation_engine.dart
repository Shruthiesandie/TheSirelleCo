import '../models/user_profile.dart';
import '../models/product.dart';

/// Hybrid AI Recommendation Engine
/// MCA Minor Project – Rule-based + Learning-based System
class RecommendationEngine {
  static final UserProfile _profile = UserProfile(
    name: 'local_user',
    birth: '2000-01-01',
    height: '0.0',
    blood: '',
    constellation: '',
    avatarPath: '',
  );

  // =====================
  // TRACKING (LEARNING)
  // =====================

  static void trackCategoryClick(String categoryKey) {
    _profile.categoryClicks[categoryKey] =
        (_profile.categoryClicks[categoryKey] ?? 0) + 1;
  }

  static void trackProductView(Product product) {
    _profile.productViews[product.imageUrl] =
        (_profile.productViews[product.imageUrl] ?? 0) + 1;
  }

  static void trackAddToCart(Product product) {
    _profile.addToCartCounts[product.imageUrl] =
        (_profile.addToCartCounts[product.imageUrl] ?? 0) + 1;
  }

  // =====================
  // RECOMMENDATION CORE
  // =====================

  static List<Product> recommend({
    required List<Product> allProducts,
    String? category,
    double? budget,
    int limit = 6, required vibe,
  }) {
    // ---------- RULE-BASED FILTERING ----------
    final filtered = allProducts.where((product) {
      if (budget != null && product.price > budget) return false;

      if (category != null && product.category != category) {
        return false;
      }

      return true;
    }).toList();

    // ---------- LEARNING-BASED SCORING ----------
    filtered.sort((a, b) {
      final scoreA = _score(a, budget);
      final scoreB = _score(b, budget);
      return scoreB.compareTo(scoreA);
    });

    return filtered.take(limit).toList();
  }

  // =====================
  // SCORING FUNCTION
  // =====================

  static double _score(Product product, double? budget) {
    final categoryPreference =
        (_profile.categoryClicks[product.category] ?? 0) * 0.4;

    final productInterest =
        (_profile.productViews[product.imageUrl] ?? 0) * 0.2;

    final cartIntent =
        (_profile.addToCartCounts[product.imageUrl] ?? 0) * 0.2;

    final budgetMatch =
        (budget != null && product.price <= budget) ? 0.3 : 0.0;

    return categoryPreference +
        productInterest +
        cartIntent +
        budgetMatch;
  }
}