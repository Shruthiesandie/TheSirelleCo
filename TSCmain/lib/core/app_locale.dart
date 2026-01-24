import 'package:flutter/material.dart';

class AppLocale {
  static final ValueNotifier<Locale> locale =
      ValueNotifier(const Locale('en'));

  static void set(Locale newLocale) {
    locale.value = newLocale;
  }
}