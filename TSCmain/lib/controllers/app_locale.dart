import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class AppLocale {
  static final ValueNotifier<Locale> locale =
      ValueNotifier(const Locale('en'));

  static const _key = 'app_locale';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    locale.value = Locale(code);
  }

  static Future<void> set(Locale newLocale) async {
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newLocale.languageCode);
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  static const localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}