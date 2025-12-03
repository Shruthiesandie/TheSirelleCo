import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,

    // Main scaffold background
    scaffoldBackgroundColor: const Color(0xFFFCEEEE), // soft pink

    // Color scheme base
    colorScheme: const ColorScheme.light(
      primary: Colors.pinkAccent,
      secondary: Colors.pinkAccent,
      surface: Colors.white,
      background: Color(0xFFFCEEEE),
    ),

    // AppBar default styling
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.black.withOpacity(.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      elevation: 5,
    ),

    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 22,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.pinkAccent,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
      bodyLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
      bodyMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
    ),

    dividerColor: Colors.black12,
  );
}
