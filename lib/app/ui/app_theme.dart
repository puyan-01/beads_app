import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';
import 'theme_tokens.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.colorPrimary,
    primary: AppColors.colorPrimary,
    secondary: AppColors.colorAccent,
    surface: AppColors.bgCard,
    error: AppColors.colorError,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bgPage,
    textTheme: const TextTheme(
      displaySmall: AppTextStyles.titlePage,
      titleLarge: AppTextStyles.titleSection,
      bodyMedium: AppTextStyles.body,
      bodyLarge: AppTextStyles.bodyLarge,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.buttonText,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
    ),
    extensions: const [ThemeTokens.defaults],
  );
}
