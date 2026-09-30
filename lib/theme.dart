import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from the "Personality Path v2" design (dark green theme).
class AppColors {
  static const bg = Color(0xFF1C1F27);
  static const surface = Color(0xFF262A34);
  static const text = Color(0xFFF4F6F5);
  static const accent = Color(0xFF3EE865);
  static const accent2 = Color(0xFFA3EF45);
  static const deep = Color(0xFF101217);
  static const page = Color(0xFF0F1116);
  static Color get divider => text.withValues(alpha: 0.14);

  static const neutral100 = Color(0xFF2C313C);
  static const neutral200 = Color(0xFF313743);
  static const neutral300 = Color(0xFF3A404D);
  static const neutral400 = Color(0xFF4B5260);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF8A919D);
  static const neutral700 = Color(0xFFA3AAB5);
  static const neutral800 = Color(0xFFC9CED6);
  static const neutral900 = Color(0xFF0C0E12);

  static const accent100 = Color(0xFF173322);
  static const accent200 = Color(0xFF1D4A2C);
  static const accent300 = Color(0xFF256B3A);
  static const accent400 = Color(0xFF2FB052);
  static const accent500 = Color(0xFF3EE865);
  static const accent600 = Color(0xFF5FF07F);
  static const accent700 = Color(0xFF7EF59A);
  static const accent800 = Color(0xFFA6F8B8);
  static const accent900 = Color(0xFFD2FCDC);

  static const accent2_100 = Color(0xFF26331A);
  static const accent2_200 = Color(0xFF34491F);
  static const accent2_300 = Color(0xFF4B6A28);
  static const accent2_400 = Color(0xFF7FB536);
  static const accent2_500 = Color(0xFFA3EF45);
  static const accent2_600 = Color(0xFFB5F36A);
  static const accent2_700 = Color(0xFFC6F68D);
  static const accent2_800 = Color(0xFFD9F9B3);
  static const accent2_900 = Color(0xFFECFCD8);

  static const gradient = LinearGradient(
    colors: [Color(0xFF34E75A), Color(0xFFA3EF45)],
  );

  static List<BoxShadow> get glow => [
        BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 28),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 40,
            offset: const Offset(0, 14)),
      ];
}

/// Heading font (Archivo Black) and body font (Rubik).
TextStyle heading(double size, {Color color = AppColors.text, double? height}) =>
    GoogleFonts.archivoBlack(
        fontSize: size, color: color, height: height ?? 1.15, letterSpacing: -0.2);

TextStyle body(double size,
        {Color color = AppColors.text,
        FontWeight weight = FontWeight.w400,
        double? height,
        TextDecoration? decoration,
        double? letterSpacing}) =>
    GoogleFonts.rubik(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        decoration: decoration,
        decorationColor: color,
        letterSpacing: letterSpacing);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.surface,
      onPrimary: AppColors.bg,
    ),
    textTheme: GoogleFonts.rubikTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: Color(0x4D3EE865),
      selectionHandleColor: AppColors.accent,
    ),
  );
}
