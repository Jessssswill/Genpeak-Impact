import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { dark, gray, light }

class _ColorSchemeData {
  const _ColorSchemeData({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.surfaceCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.cardBorder,
    required this.overlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceCard;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color cardBorder;
  final Color overlay;

  // ── Midnight Ocean — deep navy-indigo ──
  static const _ColorSchemeData dark = _ColorSchemeData(
    background:   Color(0xFF080C14),
    surface:      Color(0xFF0F1623),
    surfaceLight: Color(0xFF162033),
    surfaceCard:  Color(0xFF121D2E),
    textPrimary:  Color(0xFFF0F4F8),
    textSecondary:Color(0xFF8899AB),
    textMuted:    Color(0xFF4A5E73),
    divider:      Color(0xFF1A2A3D),
    cardBorder:   Color(0xFF1E3048),
    overlay:      Color(0xE6080C14),
  );

  // ── Graphite — warm charcoal, clearly distinct from dark ──
  static const _ColorSchemeData gray = _ColorSchemeData(
    background:   Color(0xFF131316),
    surface:      Color(0xFF1C1C21),
    surfaceLight: Color(0xFF26262C),
    surfaceCard:  Color(0xFF1F1F25),
    textPrimary:  Color(0xFFECEDF0),
    textSecondary:Color(0xFF7C7D85),
    textMuted:    Color(0xFF4E4F56),
    divider:      Color(0xFF2A2A30),
    cardBorder:   Color(0xFF303038),
    overlay:      Color(0xE6131316),
  );

  // ── Ivory Mist — warm, airy ──
  static const _ColorSchemeData light = _ColorSchemeData(
    background:   Color(0xFFF5F6FA),
    surface:      Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFF0F2F7),
    surfaceCard:  Color(0xFFFFFFFF),
    textPrimary:  Color(0xFF111827),
    textSecondary:Color(0xFF475569),
    textMuted:    Color(0xFF94A3B8),
    divider:      Color(0xFFE2E8F0),
    cardBorder:   Color(0xFFE2E8F0),
    overlay:      Color(0xCCF5F6FA),
  );
}

class AppColors {
  static _ColorSchemeData _scheme = _ColorSchemeData.dark;

  static void applyMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:  _scheme = _ColorSchemeData.dark;  break;
      case AppThemeMode.gray:  _scheme = _ColorSchemeData.gray;  break;
      case AppThemeMode.light: _scheme = _ColorSchemeData.light; break;
    }
  }

  static Color get background    => _scheme.background;
  static Color get surface       => _scheme.surface;
  static Color get surfaceLight  => _scheme.surfaceLight;
  static Color get surfaceCard   => _scheme.surfaceCard;
  static Color get textPrimary   => _scheme.textPrimary;
  static Color get textSecondary => _scheme.textSecondary;
  static Color get textMuted     => _scheme.textMuted;
  static Color get divider       => _scheme.divider;
  static Color get cardBorder    => _scheme.cardBorder;
  static Color get overlay       => _scheme.overlay;

  // ── Luminous accents ──
  static const Color primary      = Color(0xFF34D8C0);
  static const Color primaryLight = Color(0xFF5EEAD4);
  static const Color primaryDark  = Color(0xFF14B8A6);

  static const Color secondary      = Color(0xFFF0C95C);
  static const Color secondaryLight = Color(0xFFFFD97A);
  static const Color secondaryDark  = Color(0xFFD4A42E);

  static const Color danger  = Color(0xFFEF5555);
  static const Color success = Color(0xFF22D3A7);
  static const Color warning = Color(0xFFFBBF4E);
  static const Color info    = Color(0xFF38BDF8);

  // ── Enriched element colors ──
  static const Color pyro    = Color(0xFFFF6B3D);
  static const Color hydro   = Color(0xFF38BDF8);
  static const Color electro = Color(0xFFA78BFA);
  static const Color cryo    = Color(0xFF67E8F9);
  static const Color dendro  = Color(0xFF84CC16);
  static const Color anemo   = Color(0xFF34D399);
  static const Color geo     = Color(0xFFFBBF24);

  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'pyro':    return pyro;
      case 'hydro':   return hydro;
      case 'electro': return electro;
      case 'cryo':    return cryo;
      case 'dendro':  return dendro;
      case 'anemo':   return anemo;
      case 'geo':     return geo;
      default:        return primary;
    }
  }

  static const Color rarity5 = Color(0xFFF0A93E);
  static const Color rarity4 = Color(0xFFA78BFA);
  static const Color rarity3 = Color(0xFF38BDF8);
}

class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
}

class AppRadius {
  static const double sm     = 8;
  static const double md     = 12;
  static const double lg     = 16;
  static const double card   = 16;
  static const double button = 12;
  static const double input  = 12;
  static const double badge  = 20;
  static const double xl     = 20;
  static const double full   = 999;
}

class AppTheme {
  static ThemeData themeFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:  return _build(brightness: Brightness.dark);
      case AppThemeMode.gray:  return _build(brightness: Brightness.dark);
      case AppThemeMode.light: return _build(brightness: Brightness.light);
    }
  }

  static ThemeData get darkTheme  => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:    AppColors.primary,
        onPrimary:  isLight ? Colors.white : const Color(0xFF042F2E),
        secondary:  AppColors.secondary,
        onSecondary: const Color(0xFF1A1000),
        surface:    AppColors.surface,
        onSurface:  AppColors.textPrimary,
        error:      AppColors.danger,
        onError:    Colors.white,
      ),

      textTheme: baseTextTheme.copyWith(
        headlineLarge:  baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 28, letterSpacing: -0.5),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.3),
        headlineSmall:  baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:     baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium:    baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge:      baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
        bodyMedium:     baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        bodySmall:      baseTextTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 12, height: 1.4),
        labelLarge:     baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:    baseTextTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall:     baseTextTheme.labelSmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 10),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF042F2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
