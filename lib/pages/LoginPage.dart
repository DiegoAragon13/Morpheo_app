import 'package:flutter/material.dart';
import 'package:morpheo_app/pages/register_page.dart';
import 'package:morpheo_app/pages/register_page.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'main_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ Método actualizado con Cognito
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Llamar a AWS Cognito
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success']
                ? const Color(0xFF00E676)
                : const Color(0xFFFF5252),
          ),
        );

        if (result['success']) {
          //
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      }
    }
  }


  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu email primero'),
          backgroundColor: Color(0xFFFFD600),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.forgotPassword(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success']
              ? const Color(0xFF00E676)
              : const Color(0xFFFF5252),
        ),
      );
    }
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
              Color(0xFF1A237E),
              Color(0xFF4A148C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Logo y título
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2C2C34),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D5AFE).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bedtime,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Morpheo",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Monitorea tu sueño inteligentemente",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE0E0E0),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Card de formulario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C34),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo Email
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "tu@email.com",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF42424A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              }
                              if (!value.contains('@')) {
                                return 'Email no válido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Campo Contraseña
                          const Text(
                            "Contraseña",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "••••••••",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF42424A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFE0E0E0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFE0E0E0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ¿Olvidaste tu contraseña?
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : _handleForgotPassword,
                              child: const Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF3D5AFE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Botón Iniciar Sesión
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A237E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1A237E),
                                  ),
                                ),
                              )
                                  : const Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Registrarse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿No tienes cuenta? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3D5AFE),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}