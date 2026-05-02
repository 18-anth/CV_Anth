// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';

/// 🌐 Servicio de autenticación de Google usando Google Identity Services (GIS)
/// Implementación web-only que NO depende del package google_sign_in
///
/// Usa directamente la API de JavaScript de Google Identity Services
/// Similar a la implementación de React mostrada por el usuario
class GoogleAuthWeb {
  static String? _accessToken;
  static bool _isInitialized = false;

  /// Carga el script de Google Identity Services
  static Future<void> _loadGoogleIdentityServices() async {
    if (!kIsWeb) {
      throw Exception('Este servicio solo funciona en web');
    }

    final completer = Completer<void>();

    // Verificar si ya está cargado
    if (_checkIfGoogleLoaded()) {
      completer.complete();
      return completer.future;
    }

    // Cargar script dinámicamente
    final script = html.ScriptElement()
      ..src = 'https://accounts.google.com/gsi/client'
      ..async = true
      ..defer = true;

    script.onLoad.listen((_) => completer.complete());
    script.onError.listen((_) {
      completer.completeError(Exception('Error al cargar GIS'));
    });

    html.document.head!.append(script);

    return completer.future;
  }

  /// Verifica si Google Identity Services ya está cargado
  static bool _checkIfGoogleLoaded() {
    try {
      return js.context.hasProperty('google') &&
          js.context['google'] != null &&
          js.context['google']['accounts'] != null;
    } catch (e) {
      return false;
    }
  }

  /// Solicita un access token OAuth2 al usuario
  /// Abre el popup de Google solo si no hay token previo
  static Future<String> requestAccessToken() async {
    if (!kIsWeb) {
      throw Exception('Este servicio solo funciona en web');
    }

    await _loadGoogleIdentityServices();

    final completer = Completer<String>();

    try {
      // Callback para manejar la respuesta
      js.context['_googleAuthCallback'] = js.allowInterop((dynamic response) {
        try {
          final error = response['error'];
          if (error != null) {
            completer.completeError(
              Exception('Error de autenticación: $error'),
            );
            return;
          }

          final token = response['access_token'];
          if (token != null) {
            _accessToken = token as String;
            _isInitialized = true;
            completer.complete(_accessToken!);
          } else {
            completer.completeError(Exception('No se recibió token'));
          }
        } catch (e) {
          completer.completeError(Exception('Error procesando respuesta: $e'));
        }
      });

      // Crear token client con la API de JavaScript
      final google = js.context['google'];
      final accounts = google['accounts'];
      final oauth2 = accounts['oauth2'];

      final tokenClient = oauth2.callMethod('initTokenClient', [
        js.JsObject.jsify({
          'client_id': AppConfig.googleClientId,
          'scope': 'https://www.googleapis.com/auth/drive.file',
          'callback': js.context['_googleAuthCallback'],
        }),
      ]);

      // Solicitar token (prompt: '' reutiliza sesión sin popup si ya fue autorizado)
      tokenClient.callMethod('requestAccessToken', [
        js.JsObject.jsify({'prompt': ''}),
      ]);
    } catch (e) {
      completer.completeError(Exception('Error al solicitar token: $e'));
    }

    return completer.future;
  }

  /// Obtiene el token actual o solicita uno nuevo
  static Future<String> getToken() async {
    if (_accessToken != null) {
      return _accessToken!;
    }
    return await requestAccessToken();
  }

  /// Verifica si hay un token válido
  static bool isAuthenticated() {
    return _accessToken != null && _isInitialized;
  }

  /// Limpia el token (logout)
  static void clearToken() {
    _accessToken = null;
    _isInitialized = false;
  }
}
