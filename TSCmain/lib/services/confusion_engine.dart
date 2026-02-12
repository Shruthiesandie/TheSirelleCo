import 'package:flutter/material.dart';
import '../widgets/ai_help_popup.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api.dart';
class ConfusionEngine {
  static final List<Map<String, dynamic>> _events = [];

  static BuildContext? appContext;

  static void setContext(BuildContext context) {
    appContext = context;
  }

  // --------------------------------------------------
  // 🔥 Send confusion event to backend (MySQL)
  // --------------------------------------------------
  static Future<void> _recordConfusionBackend(
    String screen,
    String reason,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/ai/confusion-event"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": user.uid,
          "screen": screen,
          "reason": reason,
        }),
      );
    } catch (e) {
      print("Backend confusion log failed: $e");
    }
  }

  static void record({
    required String userId,
    required String screen,
    required String type,
    required String value,
  }) {
    _events.add({
      "userId": userId,
      "screen": screen,
      "type": type,
      "value": value,
      "time": DateTime.now(),
    });

    _checkConfusion(userId);
  }

  static void _checkConfusion(String userId) {
    final now = DateTime.now();

    final recent = _events.where((e) =>
        e["userId"] == userId &&
        now.difference(e["time"]).inSeconds <= 20).toList();

    // 🔥 RULE 1 — repeated search
    final searches =
        recent.where((e) => e["type"] == "search").map((e) => e["value"]).toList();
    if (searches.length >= 3 && searches.toSet().length == 1) {
      // 🧠 Only show search help when CURRENT screen is search_page
      final currentScreen = recent.isNotEmpty ? recent.last["screen"] : null;

      if (currentScreen == "search_page") {
        if (appContext != null) {
          AIHelpPopup.show(
            appContext!,
            "Having trouble? Try refining your search 🔍",
          );
        }
        _recordConfusionBackend("search_page", "repeated_search");
      }
    }

    // 🔥 RULE 2 — rapid clicks
    final clicks = recent.where((e) => e["type"] == "click").length;
    if (clicks >= 5) {
      if (appContext != null) {
        AIHelpPopup.show(
          appContext!,
          "Looks like something isn’t working. Need help?",
        );
      }
      _recordConfusionBackend("product_details_page", "rapid_clicking");
    }

    // 🔥 RULE 3 — navigation loop
    final nav = recent
        .where((e) => e["type"] == "navigation")
        .map((e) => e["value"])
        .toList();
    if (nav.length >= 4 && nav[0] == nav[2] && nav[1] == nav[3]) {
      if (appContext != null) {
        AIHelpPopup.show(
          appContext!,
          "Can’t find what you’re looking for? Let me help 😊",
        );
      }
      _recordConfusionBackend("home_page", "navigation_loop");
    }
  }
}