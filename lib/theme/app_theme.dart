import 'package:flutter/material.dart';

/// Tema Material 3 de SISSTeApp (azul), claro y oscuro. La app lo
/// elige según el modo del sistema (ThemeMode.system).
///
/// Los colores del encargo se aplican tal cual. Los roles que el encargo
/// no define (onSecondary, tertiary, onTertiary, shadow, scrim…) se
/// completaron con valores coherentes con la paleta.
///
/// En el resto de la app NUNCA se usan colores fijos: siempre se lee
/// `Theme.of(context).colorScheme.<rol>`.
class AppTheme {
  AppTheme._();

  static const ColorScheme _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0B57D0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD3E3FD),
    onPrimaryContainer: Color(0xFF041E49),
    secondary: Color(0xFF5A5C7C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE2F9),
    onSecondaryContainer: Color(0xFF131C2B),
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8EE),
    onTertiaryContainer: Color(0xFF2E1125),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFAF9FD),
    onSurface: Color(0xFF1B1B1F),
    onSurfaceVariant: Color(0xFF44474E),
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C6D0),
    surfaceContainerLow: Color(0xFFF3F3FA),
    surfaceContainer: Color(0xFFEEEDF3),
    surfaceContainerHigh: Color(0xFFE9E8EF),
    surfaceContainerHighest: Color(0xFFE3E2E6),
    inverseSurface: Color(0xFF303034),
    onInverseSurface: Color(0xFFF2F0F4),
    inversePrimary: Color(0xFFA8C7FA),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFC0C2FD),
    onPrimary: Color(0xFF042C71),
    primaryContainer: Color(0xFF04409F),
    onPrimaryContainer: Color(0xFFE0E0FC),
    secondary: Color(0xFFC3C3E9),
    onSecondary: Color(0xFF2C2E4C),
    secondaryContainer: Color(0xFF424463),
    onSecondaryContainer: Color(0xFFE0E0FE),
    tertiary: Color(0xFFE6B8D1),
    onTertiary: Color(0xFF4A2139),
    tertiaryContainer: Color(0xFF6E334E),
    onTertiaryContainer: Color(0xFFFFD8E7),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF131317),
    onSurface: Color(0xFFE2E2E8),
    onSurfaceVariant: Color(0xFFC6C5D2),
    outline: Color(0xFF90909C),
    outlineVariant: Color(0xFF464651),
    surfaceContainerLow: Color(0xFF1B1B1F),
    surfaceContainer: Color(0xFF1F1F23),
    surfaceContainerHigh: Color(0xFF2A2A2E),
    surfaceContainerHighest: Color(0xFF343439),
    inverseSurface: Color(0xFFE2E2E8),
    onInverseSurface: Color(0xFF303034),
    inversePrimary: Color(0xFF3757BA),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData get light => _build(_light);
  static ThemeData get dark => _build(_dark);

  static ThemeData _build(ColorScheme scheme) {
    final pill = const StadiumBorder();
    const buttonSize = Size(64, 56);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        toolbarHeight: 64,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceContainer,
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        helperStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? scheme.primary : null;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.secondaryContainer,
        circularTrackColor: scheme.secondaryContainer,
        strokeCap: StrokeCap.round,
        linearMinHeight: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        elevation: const WidgetStatePropertyAll(0),
        constraints: const BoxConstraints(minHeight: 56),
        shape: WidgetStatePropertyAll(pill),
      ),
    );
  }
}
