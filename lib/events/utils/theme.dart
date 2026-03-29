import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 24, 27, 37);
  static const Color secondary = Color(0xFF7209B7);
  static const Color accent = Color(0xFFF72585);
  static const Color surface = Color(0xFFF8F9FA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 10, 12, 22),
        secondary: const Color.fromARGB(255, 62, 41, 76),
        surface: surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 18, 22, 36),
          foregroundColor: const Color.fromARGB(255, 255, 253, 253),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    
    /*  cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: Colors.white,
      ),*/
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static const List<Color> forumColors = [
    Color(0xFF4361EE),
    Color(0xFF7209B7),
    Color(0xFFF72585),
    Color(0xFF4CC9F0),
    Color(0xFF3A0CA3),
    Color(0xFF06D6A0),
    Color(0xFFFF9F1C),
    Color(0xFFE63946),
  ];
}