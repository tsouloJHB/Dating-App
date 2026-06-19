import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkPrimaryAction = Color(0xFFFF0000);
  static const Color darkPremiumAccent = Color(0xFFFFD700);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  // Light Mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightPrimaryAction = Color(0xFFE60000);
  static const Color lightPremiumAccent = Color(0xFFD4AF37);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;
}

class AppTypography {
  static const String headingFamily = 'Montserrat';
  static const String bodyFamily = 'Inter';
}

class AppRadii {
  static const double card = 24;
  static const double control = 24;
}

class AppTextStyles {
  // Headers
  static TextStyle headerBold({
    Color color = AppColors.darkTextPrimary,
    double fontSize = 32,
  }) =>
      TextStyle(
        fontFamily: AppTypography.headingFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headerSemiBold({
    Color color = AppColors.darkTextPrimary,
    double fontSize = 24,
  }) =>
      TextStyle(
        fontFamily: AppTypography.headingFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body
  static TextStyle bodyRegular({
    Color color = AppColors.darkTextPrimary,
    double fontSize = 16,
  }) =>
      TextStyle(
        fontFamily: AppTypography.bodyFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      );

  // Caption
  static TextStyle captionSmall({
    Color color = AppColors.darkTextPrimary,
    double fontSize = 12,
  }) =>
      TextStyle(
        fontFamily: AppTypography.bodyFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      );
}

class AppTheme {
  static ThemeData darkTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.bodyFamily,
        fontFamilyFallback: const [AppTypography.headingFamily],
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.darkPrimaryAction,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimaryAction,
          secondary: AppColors.darkPremiumAccent,
          surface: AppColors.darkSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimaryAction,
            foregroundColor: AppColors.darkBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.headerBold(),
          displayMedium: AppTextStyles.headerSemiBold(),
          bodyLarge: AppTextStyles.bodyRegular(),
          bodySmall: AppTextStyles.captionSmall(),
        ),
      );

  static ThemeData lightTheme() => ThemeData(
        useMaterial3: true,
      fontFamily: AppTypography.bodyFamily,
      fontFamilyFallback: const [AppTypography.headingFamily],
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        primaryColor: AppColors.lightPrimaryAction,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimaryAction,
          secondary: AppColors.lightPremiumAccent,
          surface: AppColors.lightSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimaryAction,
            foregroundColor: AppColors.lightBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.headerBold(
            color: AppColors.lightTextPrimary,
          ),
          displayMedium: AppTextStyles.headerSemiBold(
            color: AppColors.lightTextPrimary,
          ),
          bodyLarge: AppTextStyles.bodyRegular(
            color: AppColors.lightTextPrimary,
          ),
          bodySmall: AppTextStyles.captionSmall(
            color: AppColors.lightTextPrimary,
          ),
        ),
      );
}
