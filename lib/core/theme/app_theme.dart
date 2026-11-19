import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class AppColors {
  static const skyTop = Color(0xFF0B5FD8);
  static const skyMid = Color(0xFF2F9BF0);
  static const aqua = Color(0xFF1CC0D4);
  static const seaGreen = Color(0xFF5CCB7A);

  static const background = Color(0xFFEAF9F5);
  static const surface = Color(0x80FFFFFF); // blanco 50%
  static const border = Color(0x2E0B3C5D); // azul oscuro 18%
  static const textPrimary = Color(0xFF0B3C5D);
  static const textSecondary = Color(0xB30B3C5D);
  static const primary = Color(0xFF1FA463); // verde
}

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.aqua,
      brightness: Brightness.light,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );

  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
  );
}