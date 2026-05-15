import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { dark, gray, light }

// ── Internal color scheme data ────────────────────────────────────────────────

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

  static const _ColorSchemeData dark = _ColorSchemeData(
    background:   Color(0xFF121820),
    surface:      Color(0xFF1B2230),
    surfaceLight: Color(0xFF232D3F),
    surfaceCard:  Color(0xFF1E2736),
    textPrimary:  Color(0xFFD8DEE6),
    textSecondary:Color(0xFF8895A5),
    textMuted:    Color(0xFF566170),
    divider:      Color(0xFF283040),
    cardBorder:   Color(0xFF2A3344),
    overlay:      Color(0xCC121820),
  );

  static const _ColorSchemeData gray = _ColorSchemeData(
    background:   Color(0xFF1C1C1E),
    surface:      Color(0xFF2C2C2E),
    surfaceLight: Color(0xFF38383A),
    surfaceCard:  Color(0xFF323234),
    textPrimary:  Color(0xFFE5E5EA),
    textSecondary:Color(0xFF8E8E93),
    textMuted:    Color(0xFF636366),
    divider:      Color(0xFF38383A),
    cardBorder:   Color(0xFF3A3A3C),
    overlay:      Color(0xCC1C1C1E),
  );

  static const _ColorSchemeData light = _ColorSchemeData(
    background:   Color(0xFFF2F4F8),
    surface:      Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFF8F9FB),
    surfaceCard:  Color(0xFFFFFFFF),
    textPrimary:  Color(0xFF1A1D23),
    textSecondary:Color(0xFF4A5568),
    textMuted:    Color(0xFF718096),
    divider:      Color(0xFFE2E8F0),
    cardBorder:   Color(0xFFDEE3ED),
    overlay:      Color(0xCCF2F4F8),
  );
}

// ── AppColors ─────────────────────────────────────────────────────────────────

class AppColors {
  // ── Dynamic (theme-sensitive) ──
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

  // ── Primary: Muted Teal (static) ──
  static const Color primary      = Color(0xFF6BA89A);
  static const Color primaryLight = Color(0xFF8CC4B6);
  static const Color primaryDark  = Color(0xFF4E8A7C);

  // ── Secondary: Soft Gold (static) ──
  static const Color secondary      = Color(0xFFBFA76A);
  static const Color secondaryLight = Color(0xFFD4C08E);
  static const Color secondaryDark  = Color(0xFF9E8A50);

  // ── Semantic (static) ──
  static const Color danger  = Color(0xFFCF6B6B);
  static const Color success = Color(0xFF6BAF8D);
  static const Color warning = Color(0xFFCFB86B);
  static const Color info    = Color(0xFF6B96CF);

  // ── Element Colors (static) ──
  static const Color pyro    = Color(0xFFD47A3E);
  static const Color hydro   = Color(0xFF4EAAD4);
  static const Color electro = Color(0xFF9E72C4);
  static const Color cryo    = Color(0xFF8BBFC9);
  static const Color dendro  = Color(0xFF6DA832);
  static const Color anemo   = Color(0xFF66AD96);
  static const Color geo     = Color(0xFFCFA63A);

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

  // ── Rarity Colors (static) ──
  static const Color rarity5 = Color(0xFFCF9A3E);
  static const Color rarity4 = Color(0xFF9E72C4);
  static const Color rarity3 = Color(0xFF4EAAD4);
}

// ── AppSpacing / AppRadius ────────────────────────────────────────────────────

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
  static const double card   = 14;
  static const double button = 10;
  static const double input  = 10;
  static const double badge  = 20;
  static const double xl     = 20;
  static const double full   = 999;
}

// ── AppTheme ──────────────────────────────────────────────────────────────────

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
        onPrimary:  isLight ? Colors.white : Colors.white,
        secondary:  AppColors.secondary,
        onSecondary: Colors.white,
        surface:    AppColors.surface,
        onSurface:  AppColors.textPrimary,
        error:      AppColors.danger,
        onError:    Colors.white,
      ),

      textTheme: baseTextTheme.copyWith(
        headlineLarge:  baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 26),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        headlineSmall:  baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
        titleLarge:     baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        titleMedium:    baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge:      baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium:     baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 14),
        bodySmall:      baseTextTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 12),
        labelLarge:     baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:    baseTextTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall:     baseTextTheme.labelSmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 10),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
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
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
    );
  }
}
