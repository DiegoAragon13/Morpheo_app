import 'package:flutter/material.dart';
import 'package:morpheo_app/services/auth_service.dart';
import 'dart:async';
import 'LoginPage.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _codeController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código'),
          backgroundColor: Color(0xFFFFD600),
        ),
      );
      return;
    }

    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El código debe tener 6 dígitos'),
          backgroundColor: Color(0xFFFFD600),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.confirmSignUp(
      email: widget.email,
      code: _codeController.text,
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

        // Esperar un momento y navegar al login
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        }
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

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    final result = await _authService.resendConfirmationCode(widget.email);

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
        _startResendCountdown();
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
                  SizedBox(height: size.height * 0.08),

                  // Icono de email
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
                      Icons.email_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Verifica tu Email",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Hemos enviado un código de 6 dígitos a:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D5AFE),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Card del formulario
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
                    child: Column(
                      children: [
                        const Text(
                          "Código de Verificación",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Campo de código
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            hintText: "000000",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 8,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF42424A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            counterText: "",
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botón Verificar
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerify,
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
                              "Verificar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Reenviar código
                        TextButton(
                          onPressed: _canResend && !_isLoading ? _handleResendCode : null,
                          child: Text(
                            _canResend
                                ? "Reenviar código"
                                : "Reenviar en $_resendCountdown s",
                            style: TextStyle(
                              fontSize: 14,
                              color: _canResend
                                  ? const Color(0xFF3D5AFE)
                                  : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF40C4FF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Revisa tu bandeja de spam si no ves el email",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
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