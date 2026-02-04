import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Updated to match mobile dashboard design
  static const Color primaryColor = Color(0xFFb3ee9a);    // Primary green (#b3ee9a)
  static const Color primaryLight = Color(0xFFF1FFF3);   // Light green white (#F1FFF3)
  static const Color primaryDark = Color(0xFF093030);    // Dark text (#093030)
  static const Color secondaryColor = Color(0xFF6DB6FE);  // Light blue buttons (#6DB6FE)
  static const Color accentColor = Color(0xFF0068FF);    // Ocean blue (#0068FF)
  static const Color bottomNavColor = Color(0xFFDFF7E2);  // Light green bottom nav (#DFF7E2)
  static const Color successColor = Color(0xFF90EE90);   // Light green
  static const Color warningColor = Color(0xFFFFD700);   // Yellow
  static const Color errorColor = Color(0xFFFF4444);    // Red
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF093030);    // Dark text color
  static const Color textSecondary = Color(0xFF757575);

  // Financial UI Colors
  static const Color positiveAmount = Color(0xFF2E7D32); // Green for positive amounts
  static const Color negativeAmount = Color(0xFFD32F2F); // Red for negative amounts
  static const Color neutralAmount = Color(0xFF212121);  // Dark for neutral amounts

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: textSecondary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF1a1a1a), // Dark text for green background
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1a1a1a),
        elevation: 0,
        centerTitle: true,
        shadowColor: Color(0xFFE5E5E5),
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Color(0xFF1a1a1a),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: darkTextPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: darkTextPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: darkTextPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: darkTextPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: darkTextPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: darkTextSecondary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF1a1a1a), // Dark text for green background
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        shadowColor: Color(0xFF000000),
        surfaceTintColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

