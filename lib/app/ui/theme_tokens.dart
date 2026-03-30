import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';

@immutable
class ThemeTokens extends ThemeExtension<ThemeTokens> {
  const ThemeTokens({
    required this.pageBg,
    required this.cardBg,
    required this.editorBg,
    required this.primary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.borderLight,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.radiusLarge,
    required this.radiusCard,
    required this.radiusButton,
    required this.radiusTag,
    required this.radiusTool,
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space32,
    required this.pageTransition,
    required this.pressDuration,
    required this.listEntrance,
    required this.shadowCard,
    required this.shadowFloat,
    required this.shadowModal,
  });

  final Color pageBg;
  final Color cardBg;
  final Color editorBg;
  final Color primary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color borderLight;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final double radiusLarge;
  final double radiusCard;
  final double radiusButton;
  final double radiusTag;
  final double radiusTool;

  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;

  final Duration pageTransition;
  final Duration pressDuration;
  final Duration listEntrance;

  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowFloat;
  final List<BoxShadow> shadowModal;

  static const ThemeTokens defaults = ThemeTokens(
    pageBg: AppColors.bgPage,
    cardBg: AppColors.bgCard,
    editorBg: AppColors.bgEditor,
    primary: AppColors.colorPrimary,
    accent: AppColors.colorAccent,
    success: AppColors.colorSuccess,
    warning: AppColors.colorWarning,
    error: AppColors.colorError,
    borderLight: AppColors.borderLight,
    borderStrong: AppColors.borderStrong,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    radiusLarge: AppRadius.radiusLarge,
    radiusCard: AppRadius.radiusCard,
    radiusButton: AppRadius.radiusButton,
    radiusTag: AppRadius.radiusTag,
    radiusTool: AppRadius.radiusTool,
    space4: AppSpacing.space4,
    space8: AppSpacing.space8,
    space12: AppSpacing.space12,
    space16: AppSpacing.space16,
    space20: AppSpacing.space20,
    space24: AppSpacing.space24,
    space32: AppSpacing.space32,
    pageTransition: Duration(milliseconds: 220),
    pressDuration: Duration(milliseconds: 120),
    listEntrance: Duration(milliseconds: 180),
    shadowCard: [
      BoxShadow(
        color: Color.fromRGBO(31, 41, 55, 0.06),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    shadowFloat: [
      BoxShadow(
        color: Color.fromRGBO(31, 41, 55, 0.10),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
    shadowModal: [
      BoxShadow(
        color: Color.fromRGBO(31, 41, 55, 0.14),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );

  @override
  ThemeTokens copyWith({
    Color? pageBg,
    Color? cardBg,
    Color? editorBg,
    Color? primary,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? borderLight,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    double? radiusLarge,
    double? radiusCard,
    double? radiusButton,
    double? radiusTag,
    double? radiusTool,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    Duration? pageTransition,
    Duration? pressDuration,
    Duration? listEntrance,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowFloat,
    List<BoxShadow>? shadowModal,
  }) {
    return ThemeTokens(
      pageBg: pageBg ?? this.pageBg,
      cardBg: cardBg ?? this.cardBg,
      editorBg: editorBg ?? this.editorBg,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      borderLight: borderLight ?? this.borderLight,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusButton: radiusButton ?? this.radiusButton,
      radiusTag: radiusTag ?? this.radiusTag,
      radiusTool: radiusTool ?? this.radiusTool,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space20: space20 ?? this.space20,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      pageTransition: pageTransition ?? this.pageTransition,
      pressDuration: pressDuration ?? this.pressDuration,
      listEntrance: listEntrance ?? this.listEntrance,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowFloat: shadowFloat ?? this.shadowFloat,
      shadowModal: shadowModal ?? this.shadowModal,
    );
  }

  @override
  ThemeTokens lerp(covariant ThemeExtension<ThemeTokens>? other, double t) {
    if (other is! ThemeTokens) {
      return this;
    }

    return ThemeTokens(
      pageBg: Color.lerp(pageBg, other.pageBg, t) ?? pageBg,
      cardBg: Color.lerp(cardBg, other.cardBg, t) ?? cardBg,
      editorBg: Color.lerp(editorBg, other.editorBg, t) ?? editorBg,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      borderLight: Color.lerp(borderLight, other.borderLight, t) ?? borderLight,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      radiusLarge: radiusLarge + ((other.radiusLarge - radiusLarge) * t),
      radiusCard: radiusCard + ((other.radiusCard - radiusCard) * t),
      radiusButton: radiusButton + ((other.radiusButton - radiusButton) * t),
      radiusTag: radiusTag + ((other.radiusTag - radiusTag) * t),
      radiusTool: radiusTool + ((other.radiusTool - radiusTool) * t),
      space4: space4 + ((other.space4 - space4) * t),
      space8: space8 + ((other.space8 - space8) * t),
      space12: space12 + ((other.space12 - space12) * t),
      space16: space16 + ((other.space16 - space16) * t),
      space20: space20 + ((other.space20 - space20) * t),
      space24: space24 + ((other.space24 - space24) * t),
      space32: space32 + ((other.space32 - space32) * t),
      pageTransition: t < 0.5 ? pageTransition : other.pageTransition,
      pressDuration: t < 0.5 ? pressDuration : other.pressDuration,
      listEntrance: t < 0.5 ? listEntrance : other.listEntrance,
      shadowCard: t < 0.5 ? shadowCard : other.shadowCard,
      shadowFloat: t < 0.5 ? shadowFloat : other.shadowFloat,
      shadowModal: t < 0.5 ? shadowModal : other.shadowModal,
    );
  }
}

extension ThemeTokensX on BuildContext {
  ThemeTokens get tokens => Theme.of(this).extension<ThemeTokens>() ?? ThemeTokens.defaults;
}
