import 'package:flutter/material.dart';

/// 🔐 AuthController - Controlador de autenticación
/// Gestiona el estado de autenticación de la aplicación
class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Intenta hacer login con email y contraseña
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));

      // Validación básica (puedes conectar a Firebase aquí)
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

      // ✅ Login exitoso
      _isAuthenticated = true;
      _userEmail = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
