import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

/// 🔐 EnvLoader - Cargador seguro de variables de entorno
/// Soporta móviles (assets/env.txt) y web (.env)
class EnvLoader {
  static Map<String, String> _env = {};
  static bool _isLoaded = false;

  /// Carga las variables de entorno desde el archivo apropiado
  /// - Móviles: assets/env.txt
  /// - Web: intenta .env y assets/env.txt
  static Future<void> loadEnv() async {
    if (_isLoaded) return;

    try {
      // Para web, intentar cargar desde la raíz
      // Para móviles, cargar desde assets/env.txt
      if (kIsWeb) {
        // Web: cargar desde assets/env.txt
        try {
          final content = await rootBundle.loadString('assets/env.txt');
          _env = _parseEnv(content);
          _isLoaded = true;
          return;
        } catch (e) {
          throw Exception('⚠️ No se pudo cargar assets/env.txt en web: $e');
        }
      } else {
        // Móviles: cargar desde assets/env.txt
        try {
          final content = await rootBundle.loadString('assets/env.txt');
          _env = _parseEnv(content);
          _isLoaded = true;
        } catch (e) {
          throw Exception('⚠️ No se pudo cargar assets/env.txt: $e');
        }
      }
    } catch (e) {
      throw Exception('⚠️ Error al cargar configuración de entorno: $e');
    }
  }

  /// Obtiene el valor de una variable de entorno
  /// Lanza excepción si la clave no existe (modo seguro)
  static String getRequired(String key) {
    if (!_isLoaded) {
      throw Exception(
        '⚠️ EnvLoader no ha sido inicializado. Llama a loadEnv() primero.',
      );
    }

    if (!_env.containsKey(key)) {
      throw Exception('⚠️ Variable de entorno "$key" no encontrada');
    }

    return _env[key]!;
  }

  /// Obtiene el valor de una variable de entorno o retorna un valor por defecto
  static String get(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }

  /// Obtiene un valor booleano desde las variables de entorno
  /// Acepta: 'true', 'false', '1', '0', 'yes', 'no'
  /// Retorna el valor por defecto si la clave no existe o no es válida
  static bool getBool(String key, {bool defaultValue = false}) {
    if (!_env.containsKey(key)) {
      return defaultValue;
    }

    final value = _env[key]!.toLowerCase().trim();

    // Valores que representan true
    if (value == 'true' || value == '1' || value == 'yes' || value == 'y') {
      return true;
    }

    // Valores que representan false
    if (value == 'false' || value == '0' || value == 'no' || value == 'n') {
      return false;
    }

    // Valor no reconocido, usar default
    return defaultValue;
  }

  /// Obtiene un valor entero desde las variables de entorno
  /// Retorna el valor por defecto si la clave no existe o no es un número válido
  static int getInt(String key, {int defaultValue = 0}) {
    if (!_env.containsKey(key)) {
      return defaultValue;
    }

    try {
      return int.parse(_env[key]!);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Obtiene un valor double desde las variables de entorno
  /// Retorna el valor por defecto si la clave no existe o no es un número válido
  static double getDouble(String key, {double defaultValue = 0.0}) {
    if (!_env.containsKey(key)) {
      return defaultValue;
    }

    try {
      return double.parse(_env[key]!);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Verifica si una clave existe
  static bool has(String key) => _env.containsKey(key);

  /// Obtiene todas las variables de entorno
  static Map<String, String> getAll() => Map.unmodifiable(_env);

  /// Parsea el contenido del archivo .env
  static Map<String, String> _parseEnv(String content) {
    final lines = content.split('\n');
    final env = <String, String>{};

    for (var line in lines) {
      line = line.trim();

      // Ignorar líneas vacías y comentarios
      if (line.isEmpty || line.startsWith('#')) continue;

      // Dividir por el primer =
      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) continue;

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      if (key.isNotEmpty) {
        env[key] = value;
      }
    }

    return env;
  }

  /// Limpia el estado (útil para testing)
  static void reset() {
    _env.clear();
    _isLoaded = false;
  }
}
