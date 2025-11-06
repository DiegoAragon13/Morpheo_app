import 'package:flutter/material.dart';
import 'package:morpheo_app/services/auth_service.dart';
import 'package:morpheo_app/pages/verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Color(0xFFFF5252),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: const Color(0xFF00E676),
            ),
          );

          // Navegar a verificación de email
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyEmailPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: const Color(0xFFFF5252),
            ),
          );
        }
      }
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
                  SizedBox(height: size.height * 0.04),

                  // Botón de regresar
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logo y título
                  Container(
                    width: 80,
                    height: 80,
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
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Únete a Morpheo y mejora tu sueño",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE0E0E0),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.04),

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
                          // Campo Nombre
                          const Text(
                            "Nombre completo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Diego Aragón",
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
                                Icons.person_outline,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              if (value.length < 3) {
                                return 'El nombre debe tener al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

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
                              if (!value.contains('@') || !value.contains('.')) {
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
                              hintText: "Mínimo 8 caracteres",
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
                              if (value.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Debe contener al menos una mayúscula';
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Debe contener al menos una minúscula';
                              }
                              if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Debe contener al menos un número';
                              }
                              if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                return 'Debe contener al menos un símbolo';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Campo Confirmar Contraseña
                          const Text(
                            "Confirmar contraseña",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Repite tu contraseña",
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
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFE0E0E0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu contraseña';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
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
                                "Crear Cuenta",
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

                  const SizedBox(height: 24),

                  // Ya tienes cuenta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿Ya tienes cuenta? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Inicia Sesión",
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