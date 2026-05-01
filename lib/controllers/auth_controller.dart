import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔐 AuthController - Controlador de autenticación con Firebase
/// Gestiona la autenticación usando Firebase Authentication
class AuthController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isAuthenticated => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  AuthController() {
    // Escuchar cambios en el estado de autenticación
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Intenta hacer login con email y contraseña usando Firebase
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validación básica local
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email y contraseña son requeridos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!email.contains('@')) {
        _errorMessage = 'Email inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 🔥 Autenticar con Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _currentUser = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      print('🔴 Firebase Auth Error Code: ${e.code}');
      print('🔴 Firebase Auth Error Message: ${e.message}');
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión: $e';
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  Future<bool> register(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validación básica
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email y contraseña son requeridos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!email.contains('@')) {
        _errorMessage = 'Email inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 🔥 Crear usuario en Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _currentUser = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      print('🔴 Firebase Auth Error Code: ${e.code}');
      print('🔴 Firebase Auth Error Message: ${e.message}');
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al registrarse: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout - Desconecta el usuario actual
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  /// Limpiar mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Convierte códigos de error de Firebase a mensajes en español
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return '❌ Email o contraseña incorrectos.\n\n'
            '💡 Verifica:\n'
            '• Que el email esté bien escrito\n'
            '• Que la contraseña sea correcta\n'
            '• Si no tienes cuenta, regístrate primero';
      case 'user-not-found':
        return '❌ No existe usuario con este email.\n\n'
            '💡 ¿Quieres registrarte en su lugar?';
      case 'wrong-password':
        return '❌ La contraseña es incorrecta.\n\n'
            '💡 Verifica que hayas escrito bien tu contraseña';
      case 'invalid-email':
        return '❌ El email no es válido.\n\n'
            '💡 Usa un formato válido: ejemplo@dominio.com';
      case 'user-disabled':
        return '❌ Este usuario ha sido deshabilitado.\n\n'
            '💡 Contacta al administrador';
      case 'email-already-in-use':
        return '❌ Este email ya está registrado.\n\n'
            '💡 Intenta iniciar sesión en lugar de registrarte';
      case 'operation-not-allowed':
        return '❌ El método de autenticación Email/Password no está habilitado.\n\n'
            '🔧 Solución:\n'
            '1. Ve a Firebase Console\n'
            '2. Authentication → Sign-in method\n'
            '3. Habilita "Email/Password"';
      case 'weak-password':
        return '❌ La contraseña es muy débil.\n\n'
            '💡 Usa al menos 6 caracteres';
      case 'too-many-requests':
        return '❌ Demasiados intentos fallidos.\n\n'
            '💡 Espera unos minutos antes de intentar de nuevo';
      case 'network-request-failed':
        return '❌ Error de conexión.\n\n'
            '💡 Verifica tu conexión a internet';
      default:
        return '❌ Error de autenticación: $code\n\n'
            '💡 Verifica tus credenciales e intenta de nuevo';
    }
  }
}
