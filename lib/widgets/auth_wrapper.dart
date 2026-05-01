import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cv_anth/controllers/auth_controller.dart';

/// 🔐 AuthWrapper - Widget que sincroniza el estado de autenticación
/// Envuelve la app para que siempre esté sincronizada con Firebase
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: child,
    );
  }
}

/// 🔐 Verificar si el usuario está autenticado
extension AuthContext on BuildContext {
  bool get isAuthenticated {
    final auth = watch<AuthController>();
    return auth.isAuthenticated;
  }

  String? get userEmail {
    final auth = watch<AuthController>();
    return auth.userEmail;
  }

  Future<bool> login(String email, String password) async {
    final auth = read<AuthController>();
    return await auth.login(email, password);
  }

  Future<bool> register(String email, String password) async {
    final auth = read<AuthController>();
    return await auth.register(email, password);
  }

  Future<void> logout() async {
    final auth = read<AuthController>();
    await auth.logout();
  }
}
