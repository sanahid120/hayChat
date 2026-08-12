import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  const AppTheme._();

  // ============================================================
  // DARK THEME
  // ============================================================

  static final ThemeData _darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',

    colorScheme: _darkColorScheme,

    scaffoldBackgroundColor: AppColors.scaffoldBackground,

    textTheme: _darkTextTheme,
    appBarTheme: _appBarTheme,
    inputDecorationTheme: _inputDecorationTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    iconButtonTheme: _iconButtonTheme,
    cardTheme: _cardTheme,
    dialogTheme: _dialogTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    navigationBarTheme: _navigationBarTheme,
    floatingActionButtonTheme: _floatingActionButtonTheme,
    dividerTheme: _dividerTheme,
    progressIndicatorTheme: _progressIndicatorTheme,
    checkboxTheme: _checkboxTheme,
    radioTheme: _radioTheme,
    switchTheme: _switchTheme,
    snackBarTheme: _snackBarTheme,
  );

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData _lightThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F7F9),

    textTheme: _lightTextTheme,
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF071520),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF5F6B73)),
      hintStyle: const TextStyle(color: Color(0xFF87949E)),
    ),
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    floatingActionButtonTheme: _floatingActionButtonTheme,
    progressIndicatorTheme: _progressIndicatorTheme,
  );

  // ============================================================
  // COLOR SCHEME
  // ============================================================

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.textPrimary,

    secondary: AppColors.primaryLight,
    onSecondary: AppColors.background,

    error: AppColors.error,
    onError: Colors.white,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,

    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );

  // ============================================================
  // TYPOGRAPHY
  // ============================================================

  static const TextTheme _darkTextTheme = TextTheme(
    // Large screen heading
    displaySmall: TextStyle(
      fontSize: 32,
      height: 1.20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),

    // Splash screen/app name
    headlineLarge: TextStyle(
      fontSize: 28,
      height: 1.20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
    ),

    // Authentication screen heading
    headlineMedium: TextStyle(
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),

    // Section heading
    headlineSmall: TextStyle(
      fontSize: 20,
      height: 1.30,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // AppBar title
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.30,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // ListTile and card titles
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.40,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Small titles and form labels
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.40,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Main paragraph
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.50,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    // Default body and input text
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    // Dates, descriptions and message times
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.40,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),

    // Buttons
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.20,
      fontWeight: FontWeight.w600,
      color: AppColors.textOnPrimary,
    ),

    // Text field labels
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.30,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),

    // Navigation labels and message time
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.30,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );

  static const TextTheme _lightTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFF071520),
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFF071520),
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF071520),
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF071520),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF071520),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF071520),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.50,
      color: Color(0xFF172734),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.45,
      color: Color(0xFF172734),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Color(0xFF687681),
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  // ============================================================
  // APP BAR
  // ============================================================

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    backgroundColor: AppColors.appBarBackground,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: AppColors.iconPrimary,
      size: 22,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.iconPrimary,
      size: 22,
    ),
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  // ============================================================
  // TEXT FIELDS
  // ============================================================

  static InputDecorationTheme get _inputDecorationTheme {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),

      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      ),

      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),

      floatingLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),

      prefixIconColor: AppColors.iconSecondary,
      suffixIconColor: AppColors.iconSecondary,

      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, width: 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
      disabledBorder: border(AppColors.divider),

      errorStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.error,
      ),
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  static FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.surfaceLight,
        disabledForegroundColor: AppColors.textHint,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static IconButtonThemeData get _iconButtonTheme {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.iconPrimary,
        highlightColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // CARDS AND DIALOGS
  // ============================================================

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.border,
          width: 0.6,
        ),
      ),
    );
  }

  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  static const BottomNavigationBarThemeData _bottomNavigationBarTheme =
  BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.scaffoldBackground,
    selectedItemColor: AppColors.selectedNavigation,
    unselectedItemColor: AppColors.unselectedNavigation,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
    selectedLabelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );

  static NavigationBarThemeData get _navigationBarTheme {
    return NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: AppColors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected
              ? AppColors.primary
              : AppColors.unselectedNavigation,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          size: 22,
          color: selected
              ? AppColors.primary
              : AppColors.unselectedNavigation,
        );
      }),
    );
  }

  static const FloatingActionButtonThemeData _floatingActionButtonTheme =
  FloatingActionButtonThemeData(
    elevation: 2,
    highlightElevation: 4,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  );

  // ============================================================
  // OTHER COMPONENTS
  // ============================================================

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 0.7,
    space: 1,
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme =
  ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.surfaceLight,
    circularTrackColor: AppColors.surfaceLight,
  );

  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(color: AppColors.border),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(Colors.white),
    );
  }

  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.iconSecondary;
      }),
    );
  }

  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.iconSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.surfaceLight;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(
        Colors.transparent,
      ),
    );
  }

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.surfaceLight,
    contentTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    actionTextColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  static ThemeData get lightTheme => _lightThemeData;

  static ThemeData get darkTheme => _darkThemeData;
}