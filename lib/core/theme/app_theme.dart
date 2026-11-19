import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class AppColors {
  static const skyTop = Color(0xFF0B5FD8);
  static const skyMid = Color(0xFF2F9BF0);
  static const aqua = Color(0xFF1CC0D4);
  static const seaGreen = Color(0xFF5CCB7A);

  static const background = skyTop;
  static const surface = Color(0x33FFFFFF); // blanco 20%
  static const border = Color(0x66FFFFFF); // blanco 40%
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xCCFFFFFF); // blanco 80%
  static const primary = Color(0xFF8BE04E); // verde lima
}

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.skyMid,
      brightness: Brightness.dark,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );

  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
  );
}