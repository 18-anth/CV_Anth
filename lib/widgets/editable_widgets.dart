import 'package:flutter/material.dart';
import 'package:cv_anth/main.dart' show authController;
import 'package:cv_anth/view/Auth/LoginScreen.dart';

/// 📌 Widget que muestra un banner para iniciar sesión y editar
class EditRequiresBanner extends StatefulWidget {
  final Widget child;

  const EditRequiresBanner({super.key, required this.child});

  @override
  State<EditRequiresBanner> createState() => _EditRequiresBannerState();
}

class _EditRequiresBannerState extends State<EditRequiresBanner> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Banner solo se muestra si NO está autenticado
        if (!authController.isAuthenticated)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                  top: BorderSide(color: Colors.blue[300]!, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¿Quieres editar tu perfil?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Inicia sesión para agregar o modificar tu información',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => showLoginDialog(context),
                    icon: Icon(Icons.login, size: 16),
                    label: Text('Iniciar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 🔒 Widget que muestra un botón "Editar" solo si está autenticado
class EditButton extends StatefulWidget {
  final VoidCallback onEdit;
  final String? label;

  const EditButton({super.key, required this.onEdit, this.label = 'Editar'});

  @override
  State<EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!authController.isAuthenticated) {
      return OutlinedButton.icon(
        onPressed: () => showLoginDialog(context),
        icon: Icon(Icons.login),
        label: Text('Iniciar Sesión para Editar'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
      );
    }

    return ElevatedButton.icon(
      onPressed: widget.onEdit,
      icon: Icon(Icons.edit),
      label: Text(widget.label!),
    );
  }
}

/// 🛡️ Widget que muestra un overlay si no está autenticado
class EditableContent extends StatefulWidget {
  final Widget child;
  final bool isAuthorized;

  const EditableContent({
    super.key,
    required this.child,
    this.isAuthorized = true,
  });

  @override
  State<EditableContent> createState() => _EditableContentState();
}

class _EditableContentState extends State<EditableContent> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Si no está autenticado, mostrar overlay semi-transparente
        if (!authController.isAuthenticated && !widget.isAuthorized)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => showLoginDialog(context),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 48, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Inicia sesión para editar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => showLoginDialog(context),
                        child: Text('Iniciar Sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
