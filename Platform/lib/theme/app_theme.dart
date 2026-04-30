import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF5F0EB);
  static const card = Color(0xFFFFFFFF);
  static const dark = Color(0xFF1A1510);
  static const darkMid = Color(0xFF3B2218);
  static const ink = Color(0xFF1A1510);
  static const inkSoft = Color(0xFF6B5E52);
  static const border = Color(0xFFE8E0D8);
  static const accent = Color(0xFFC0392B);
  static const accentLight = Color(0xFFF9E8E6);
  static const accent2 = Color(0xFFE8734A);
  static const green = Color(0xFF2ECC7A);
  static const greenLight = Color(0xFFE5FAF1);
  static const red = Color(0xFFC0392B);
  static const redLight = Color(0xFFFEE8E5);
  static const cameraBg = Color(0xFF0D0A08);

  static var yellow;
}

class AppTextStyles {
  static const displayFont = 'DMSerifDisplay';
  static const bodyFont = 'DMSans';

  static const TextStyle headline = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    color: AppColors.ink,
    height: 1.15,
  );

  static const TextStyle title = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    letterSpacing: 0.8,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: AppTextStyles.bodyFont,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          background: AppColors.bg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          foregroundColor: AppColors.ink,
        ),
        useMaterial3: true,
      );
}

class AppRadius {
  static const double card = 20;
  static const double cardSm = 12;
  static const double button = 16;
  static const double pill = 100;
}

class AppShadow {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.07),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get accent => [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
