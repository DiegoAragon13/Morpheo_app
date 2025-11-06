import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String userPoolId = 'us-east-2_5let0Ig3T';
  static const String clientId = '2nr5k9hr09f4rprqc4bu5h94ns';
  static const String region = 'us-east-2';

  final userPool = CognitoUserPool(userPoolId, clientId);
  CognitoUser? cognitoUser;
  CognitoUserSession? session;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Registrar usuario
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'name', value: name),
      ];

      final result = await userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );

      return {
        'success': true,
        'message': 'Verifica tu email para activar tu cuenta',
        'userConfirmed': result?.userConfirmed ?? false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  /// Confirmar registro
  Future<Map<String, dynamic>> confirmSignUp({
    required String email,
    required String code,
  }) async {
    try {
      cognitoUser = CognitoUser(email, userPool);
      final result = await cognitoUser!.confirmRegistration(code);

      return {
        'success': true,
        'message': 'Cuenta verificada exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  /// Reenviar código de verificación
  Future<Map<String, dynamic>> resendConfirmationCode(String email) async {
    try {
      cognitoUser = CognitoUser(email, userPool);
      await cognitoUser!.resendConfirmationCode();

      return {
        'success': true,
        'message': 'Código reenviado a tu email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  /// Iniciar sesión ✅ CORREGIDO
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      cognitoUser = CognitoUser(email, userPool);

      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      // ✅ Manejo correcto de nullability
      final result = await cognitoUser!.authenticateUser(authDetails);

      if (result == null) {
        return {
          'success': false,
          'message': 'Error en la autenticación',
        };
      }

      session = result;
      await _saveSession(result, email);

      return {
        'success': true,
        'message': 'Inicio de sesión exitoso',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      if (cognitoUser != null) {
        await cognitoUser!.signOut();
      }
      await _clearSession();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Verificar si hay sesión
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  /// Obtener datos del usuario actual
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (cognitoUser == null) return null;

      final attributes = await cognitoUser!.getUserAttributes();
      if (attributes == null) return null;

      Map<String, dynamic> userData = {};
      for (var attr in attributes) {
        userData[attr.getName() ?? ''] = attr.getValue() ?? '';
      }
      return userData;
    } catch (e) {
      print('Error obteniendo datos: $e');
      return null;
    }
  }

  /// Recuperar contraseña
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      cognitoUser = CognitoUser(email, userPool);
      await cognitoUser!.forgotPassword();

      return {
        'success': true,
        'message': 'Código enviado a tu email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  /// Confirmar nueva contraseña
  Future<Map<String, dynamic>> confirmPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      cognitoUser = CognitoUser(email, userPool);
      final result = await cognitoUser!.confirmPassword(code, newPassword);

      return {
        'success': true,
        'message': 'Contraseña actualizada',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.toString()),
      };
    }
  }

  // Métodos privados ✅ CORREGIDO
  Future<void> _saveSession(CognitoUserSession session, String email) async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = session.getAccessToken()?.getJwtToken();
    final idToken = session.getIdToken()?.getJwtToken();
    final refreshToken = session.getRefreshToken()?.getToken();

    if (accessToken != null) {
      await prefs.setString('accessToken', accessToken);
    }
    if (idToken != null) {
      await prefs.setString('idToken', idToken);
    }
    if (refreshToken != null) {
      await prefs.setString('refreshToken', refreshToken);
    }
    await prefs.setString('username', email);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  String _getErrorMessage(String error) {
    if (error.contains('UserNotFoundException')) {
      return 'Usuario no encontrado';
    } else if (error.contains('NotAuthorizedException')) {
      return 'Email o contraseña incorrectos';
    } else if (error.contains('UserNotConfirmedException')) {
      return 'Verifica tu email primero';
    } else if (error.contains('UsernameExistsException')) {
      return 'Este email ya está registrado';
    } else if (error.contains('InvalidPasswordException')) {
      return 'Contraseña debe tener: mínimo 8 caracteres, mayúscula, minúscula, número y símbolo';
    } else if (error.contains('CodeMismatchException')) {
      return 'Código incorrecto';
    } else if (error.contains('ExpiredCodeException')) {
      return 'Código expirado';
    } else if (error.contains('LimitExceededException')) {
      return 'Demasiados intentos. Espera unos minutos';
    } else {
      return error.replaceAll('Exception:', '').trim();
    }
  }
}