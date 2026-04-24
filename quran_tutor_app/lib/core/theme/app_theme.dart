import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.onInverseSurface,
        inversePrimary: AppColors.inversePrimary,
        shadow: AppColors.shadow,
        surfaceTint: AppColors.surfaceTint,
      ),
      // Typography
      textTheme: _textTheme,
      // AppBar Theme
      appBarTheme: _appBarTheme,
      // Card Theme
      cardTheme: _cardTheme,
      // Elevated Button Theme
      elevatedButtonTheme: _elevatedButtonTheme,
      // Outlined Button Theme
      outlinedButtonTheme: _outlinedButtonTheme,
      // Text Button Theme
      textButtonTheme: _textButtonTheme,
      // Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme,
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      // Floating Action Button Theme
      floatingActionButtonTheme: _floatingActionButtonTheme,
      // Divider Theme
      dividerTheme: _dividerTheme,
      // Chip Theme
      chipTheme: _chipTheme,
      // Dialog Theme
      dialogTheme: _dialogTheme,
      // SnackBar Theme
      snackBarTheme: _snackBarTheme,
      // List Tile Theme
      listTileTheme: _listTileTheme,
      // Tab Bar Theme
      tabBarTheme: _tabBarTheme,
      // Progress Indicator Theme
      progressIndicatorTheme: _progressIndicatorTheme,
      // Switch Theme
      switchTheme: _switchTheme,
      // Checkbox Theme
      checkboxTheme: _checkboxTheme,
      // Radio Theme
      radioTheme: _radioTheme,
      // Slider Theme
      sliderTheme: _sliderTheme,
      // Tooltip Theme
      tooltipTheme: _tooltipTheme,
      // Scaffold Background Color
      scaffoldBackgroundColor: AppColors.background,
      // Font Family
      fontFamily: 'Cairo',
      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        secondaryContainer: AppColors.secondaryContainerDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceVariant: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        background: AppColors.backgroundDark,
        onBackground: AppColors.onBackgroundDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }

  // Text Theme
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // AppBar Theme
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Card Theme
  static CardTheme get _cardTheme {
    return CardTheme(
      elevation: AppConstants.defaultElevation,
      margin: const EdgeInsets.all(AppConstants.smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        textStyle: _textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        side: const BorderSide(color: AppColors.outline),
        textStyle: _textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, AppConstants.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        textStyle: _textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: _textTheme.bodyMedium,
      hintStyle: _textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      errorStyle: _textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
      prefixIconColor: AppColors.onSurfaceVariant,
      suffixIconColor: AppColors.onSurfaceVariant,
    );
  }

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
    );
  }

  // Divider Theme
  static DividerThemeData get _dividerTheme {
    return DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
      space: AppConstants.defaultPadding,
    );
  }

  // Chip Theme
  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryContainer,
      labelStyle: _textTheme.labelMedium,
      secondaryLabelStyle: _textTheme.labelMedium?.copyWith(
        color: AppColors.onPrimaryContainer,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius / 2),
      ),
    );
  }

  // Dialog Theme
  static DialogTheme get _dialogTheme {
    return DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largePadding),
      ),
      titleTextStyle: _textTheme.headlineSmall,
      contentTextStyle: _textTheme.bodyMedium,
    );
  }

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: AppColors.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: AppColors.inversePrimary,
    );
  }

  // List Tile Theme
  static ListTileThemeData get _listTileTheme {
    return ListTileThemeData(
      tileColor: AppColors.surface,
      selectedTileColor: AppColors.primaryContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      titleTextStyle: _textTheme.bodyLarge,
      subtitleTextStyle: _textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  // Tab Bar Theme
  static TabBarTheme get _tabBarTheme {
    return TabBarTheme(
      labelStyle: _textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: _textTheme.titleSmall,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.outlineVariant,
    );
  }

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.primary,
      circularTrackColor: AppColors.surfaceVariant,
      linearTrackColor: AppColors.surfaceVariant,
    );
  }

  // Switch Theme
  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.outline;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.surfaceVariant;
      }),
    );
  }

  // Checkbox Theme
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceVariant;
      }),
      checkColor: MaterialStateProperty.all(AppColors.onPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Radio Theme
  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.outline;
      }),
    );
  }

  // Slider Theme
  static SliderThemeData get _sliderTheme {
    return SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceVariant,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.12),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: _textTheme.labelMedium?.copyWith(
        color: AppColors.onPrimary,
      ),
    );
  }

  // Tooltip Theme
  static TooltipThemeData get _tooltipTheme {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(AppConstants.smallPadding),
      ),
      textStyle: _textTheme.bodySmall?.copyWith(
        color: AppColors.onInverseSurface,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
    );
  }
}
