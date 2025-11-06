import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morpheo_app/pages/splash.dart';
// import 'package:morpheo_app/themes/theme.dart';
// import 'package:morpheo_app/pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MorpheoApp());
}

class MorpheoApp extends StatelessWidget {
  const MorpheoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morpheo',
      debugShowCheckedModeBanner: false,

      // Configurar tema principal
      theme: ThemeApp.darkTheme, // Usa el tema oscuro como principal

      // Puedes agregar el tema claro si quieres soporte para ambos modos
      // darkTheme: ThemeApp.darkTheme,
      // themeMode: ThemeMode.dark, // Forzar modo oscuro

      // Página inicial: SplashScreen
      home: const SplashScreen(),

      // Configuración de rutas (opcional)
      // routes: {
      //   '/splash': (context) => const SplashScreen(),
      //   '/login': (context) => const LoginPage(),
      //   '/register': (context) => const RegisterPage(),
      //   '/home': (context) => const HomePage(),
      // },
    );
  }
}

// Clase ThemeApp - Copia esto desde tu archivo theme.dart
class ThemeApp {
  ThemeApp._();

  // 🌙 Tema Principal - Morpheo
  static ThemeData darkTheme = ThemeData(
    splashColor: Colors.transparent,
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1A237E),
    scaffoldBackgroundColor: const Color(0xFF121212),
    shadowColor: const Color.fromARGB(50, 0, 0, 0),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1A237E),
      secondary: Color(0xFF4A148C),
      tertiary: Color(0xFF3D5AFE),
      surface: Color(0xFF2C2C34),
      surfaceContainerHighest: Color(0xFF42424A),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFE0E0E0),
      error: Color(0xFFFF5252),
    ),
  );
}