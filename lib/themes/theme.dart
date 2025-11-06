import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApp {
  ThemeApp._();

  // 🌙 Tema Principal - Morpheo
  static ThemeData darkTheme = ThemeData(
    splashColor: Colors.transparent,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1A237E),
    scaffoldBackgroundColor: const Color(0xFF121212),
    shadowColor: const Color.fromARGB(50, 0, 0, 0),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1A237E), // Azul oscuro
      secondary: Color(0xFF4A148C), // Morado profundo
      tertiary: Color(0xFF3D5AFE), // Azul neón suave
      surface: Color(0xFF2C2C34), // Gris claro para cards
      surfaceContainerHighest: Color(0xFF42424A), // Gris medio para bordes
      onPrimary: Color(0xFFFFFFFF), // Texto sobre primary
      onSecondary: Color(0xFFFFFFFF), // Texto sobre secondary
      onSurface: Color(0xFFFFFFFF), // Texto principal
      onSurfaceVariant: Color(0xFFE0E0E0), // Texto secundario
      error: Color(0xFFFF5252), // Rojo alerta
    ),
    cardColor: const Color(0xFF2C2C34),
    dividerColor: const Color(0xFF42424A),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: const Color(0xFFFFFFFF),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: const Color(0xFFE0E0E0),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: const Color(0xFFFFFFFF),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        color: const Color(0xFFFFFFFF),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFE0E0E0),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      foregroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: const Color(0xFFFFFFFF),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3D5AFE),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // 🌞 Tema Claro (opcional, para casos donde se necesite)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    splashColor: Colors.transparent,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A237E),
    shadowColor: const Color.fromARGB(30, 0, 0, 0),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A237E),
      secondary: Color(0xFF4A148C),
      tertiary: Color(0xFF3D5AFE),
      surface: Color(0xFFF5F5F5),
      surfaceContainerHighest: Color(0xFFE0E0E0),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF121212),
      onSurfaceVariant: Color(0xFF424242),
      error: Color(0xFFFF5252),
    ),
    cardColor: const Color(0xFFF5F5F5),
    dividerColor: const Color(0xFFE0E0E0),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: const Color(0xFF121212),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: const Color(0xFF424242),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: const Color(0xFF121212),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        color: const Color(0xFF121212),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF424242),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF121212),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: const Color(0xFF121212),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3D5AFE),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

// 🎨 Paleta de colores Morpheo
class MorpheoColors {
  MorpheoColors._();

  // 🌙 Colores principales
  static const Color deepBlue = Color(0xFF1A237E);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color neonBlue = Color(0xFF3D5AFE);
  static const Color electricPurple = Color(0xFF7C4DFF);

  // 💠 Colores neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteSmoke = Color(0xFFE0E0E0);
  static const Color lightGray = Color(0xFF2C2C34);
  static const Color mediumGray = Color(0xFF42424A);
  static const Color darkGray = Color(0xFF121212);

  // 🌿 Colores de estado
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // ✨ Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, deepPurple],
    stops: [0.0, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGray, deepBlue],
    stops: [0.0, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, electricPurple],
    stops: [0.0, 1.0],
  );

  // 🎭 Decoraciones útiles
  static BoxDecoration primaryGradientDecoration({double borderRadius = 12}) {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration cardGradientDecoration({double borderRadius = 12}) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration accentGradientDecoration({double borderRadius = 12}) {
    return BoxDecoration(
      gradient: accentGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: neonBlue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}