import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'LoginPage.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _morpheoTextAnimation;
  late Animation<double> _subtitleTextAnimation;
  late Animation<double> _moonAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Animación para la escala del logo (luna/icono de sueño)
    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Animación para la opacidad del logo
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Animación para el texto MORPHEO
    _morpheoTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animación para el subtítulo
    _subtitleTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Animación suave de rotación para efecto de brillo
    _moonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Navegar al Login después de completar la animación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginPage(),
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Azul oscuro
              Color(0xFF4A148C), // Morado profundo
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Efecto de estrellas en el fondo
                ...List.generate(20, (index) {
                  return Positioned(
                    left: (index * 37) % size.width,
                    top: (index * 53) % size.height,
                    child: FadeTransition(
                      opacity: _logoOpacityAnimation,
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // Contenido principal centrado
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo con gradiente y brillo
                      FadeTransition(
                        opacity: _logoOpacityAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Container(
                            width: size.width * 0.4,
                            height: size.width * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3D5AFE), // Azul neón
                                  Color(0xFF7C4DFF), // Morado eléctrico
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D5AFE).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bedtime,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Texto MORPHEO
                      FadeTransition(
                        opacity: _morpheoTextAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
                            ),
                          ),
                          child: Text(
                            "MORPHEO",
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 8.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF3D5AFE).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtítulo
                      FadeTransition(
                        opacity: _subtitleTextAnimation,
                        child: Text(
                          "SLEEP MONITORING",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE0E0E0),
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Indicador de carga con gradiente
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3D5AFE),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}