import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../widgets/ai_help_popup.dart';

// --------------------------------------------------
// 🔮 Predictive Feature Usage Engine
// --------------------------------------------------
// This engine watches navigation patterns and predicts
// which screen the user may open next.
// --------------------------------------------------

class PredictiveEngine {
  static final List<String> _navigationHistory = [];
  // 🔮 Stores learned navigation transitions (session learning)
  static final Map<String, Map<String, int>> _transitionCounts = {};
  // 🧠 Recent home navigation memory (used for smarter prediction)
  static final List<String> _recentHomeTargets = [];

  static BuildContext? appContext;
  // ⏱️ Smart anti‑spam system for AI popup
  static DateTime? _lastSuggestionTime;
  static String? _lastSuggestedPage;
  static const Duration _cooldown = Duration(seconds: 20);

  static void setContext(BuildContext context) {
    appContext = context;
  }

  // --------------------------------------------------
  // Record Navigation Events
  // --------------------------------------------------
  static void recordNavigation({
    required String userId,
    required String screen,
    required String action,
  }) {
    // We only care about navigation-type actions
    if (action != "navigation" && action != "open") return;

    _navigationHistory.add(screen);

    // Keep history small (last 6 screens)
    if (_navigationHistory.length > 6) {
      _navigationHistory.removeAt(0);
    }

    _runPrediction(userId);
  }

  // --------------------------------------------------
  // 🔮 Smart Recent-Behaviour Prediction Logic
  // --------------------------------------------------
  static void _runPrediction(String userId) {
    if (_navigationHistory.length < 2) return;

    final last = _navigationHistory[_navigationHistory.length - 1];
    final prev = _navigationHistory[_navigationHistory.length - 2];

    // --------------------------------------------------
    // 🧠 Learn transition globally (kept for backend analytics)
    // --------------------------------------------------
    _transitionCounts.putIfAbsent(prev, () => {});
    _transitionCounts[prev]![last] =
        (_transitionCounts[prev]![last] ?? 0) + 1;

    // --------------------------------------------------
    // 🔥 Learn only Home → OtherPage transitions
    // --------------------------------------------------
    if (prev == "home_page" && last != "home_page") {
      _recentHomeTargets.add(last);

      // Keep only last 6 transitions
      if (_recentHomeTargets.length > 6) {
        _recentHomeTargets.removeAt(0);
      }
    }

    // --------------------------------------------------
    // 🔮 Predict ONLY when landing on HOME
    // --------------------------------------------------
    if (last != "home_page") return;

    if (_recentHomeTargets.length < 2) return;

    // 🔥 STREAK-BASED detection (most recent repeated behaviour wins)
    String? predicted;

    final latest = _recentHomeTargets.last;
    int streak = 0;

    for (int i = _recentHomeTargets.length - 1; i >= 0; i--) {
      if (_recentHomeTargets[i] == latest) {
        streak++;
      } else {
        break;
      }
    }

    // Require at least 2 consecutive visits from home
    if (streak >= 2) {
      predicted = latest;
    }

    if (predicted != null) {
      _showSuggestion(userId, predicted!, "home_page");
    }
  }

  // --------------------------------------------------
  // Show AI Suggestion Popup
  // --------------------------------------------------
  static void _showSuggestion(
    String userId,
    String predictedScreen,
    String basedOn,
  ) {
    // 🧠 Show popup ONLY for search-based help (avoid showing on other pages)
    if (basedOn != "search_page") {
      return;
    }
    // ❗ Prevent suggesting the screen the user is already on
    final currentScreen = _navigationHistory.isNotEmpty
        ? _navigationHistory.last
        : null;

    if (currentScreen == predictedScreen) {
      return; // Don't show useless prediction
    }

    // ⏱️ Prevent spammy suggestions
    final now = DateTime.now();

    // ❌ Don't repeat same suggestion again immediately
    if (_lastSuggestedPage == predictedScreen) {
      return;
    }

    // ⏱️ Cooldown check
    if (_lastSuggestionTime != null) {
      final diff = now.difference(_lastSuggestionTime!);
      if (diff < _cooldown) {
        return;
      }
    }

    _lastSuggestionTime = now;
    _lastSuggestedPage = predictedScreen;

    if (appContext != null) {
      AIHelpPopup.show(
        appContext!,
        "💡 You often visit $predictedScreen. Want to go there?",
      );
    }

    _savePredictionBackend(userId, predictedScreen, basedOn);
  }

  // --------------------------------------------------
  // Save prediction to backend (ai_predictions table)
  // --------------------------------------------------
  static Future<void> _savePredictionBackend(
    String userId,
    String predicted,
    String basedOn,
  ) async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/ai/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "predicted_screen": predicted,
          "based_on_screen": basedOn,
        }),
      );
    } catch (e) {
      print("Prediction save failed: $e");
    }
  }
}