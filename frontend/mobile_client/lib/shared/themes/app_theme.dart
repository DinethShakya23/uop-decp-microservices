import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFF1565C0);
const Color _secondaryColor = Color(0xFF00897B);
const Color _backgroundColor = Color(0xFFF5F7FA);
const Color _surfaceColor = Color(0xFFFFFFFF);
const Color _errorColor = Color(0xFFD32F2F);

ThemeData appTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primaryColor,
    primary: _primaryColor,
    secondary: _secondaryColor,
    surface: _surfaceColor,
    error: _errorColor,
    brightness: Brightness.light,
  ).copyWith(
    surfaceContainerHighest: _backgroundColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _backgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: _surfaceColor,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 2,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _primaryColor, width: 1.5),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFF757575)),
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Color(0xFF9E9E9E),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _backgroundColor,
      selectedColor: _primaryColor.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
      space: 1,
    ),

    // Text
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
      titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF616161)),
      bodyLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF212121)),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF424242)),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF757575)),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Role color helpers
Color roleColor(String role) {
  switch (role.toUpperCase()) {
    case 'ADMIN':
      return const Color(0xFF6A1B9A);
    case 'ALUMNI':
      return const Color(0xFF00897B);
    case 'STUDENT':
    default:
      return const Color(0xFF1565C0);
  }
}
