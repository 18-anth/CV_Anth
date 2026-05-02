import 'env_loader.dart';

/// 🔐 AppConfig - Configuración centralizada y segura de la aplicación
/// Todas las rutas y constantes se cargan desde variables de entorno
class AppConfig {
  // 🔥 Firebase Configuration
  static String get apiKey => EnvLoader.getRequired('API_KEY');
  static String get authDomain => EnvLoader.getRequired('AUTH_DOMAIN');
  static String get databaseUrl => EnvLoader.getRequired('DATABASE_URL');
  static String get projectId => EnvLoader.getRequired('PROJECT_ID');
  static String get storageBucket => EnvLoader.getRequired('STORAGE_BUCKET');
  static String get messagingSenderId =>
      EnvLoader.getRequired('MESSAGING_SENDER_ID');
  static String get appId => EnvLoader.getRequired('APP_ID');
  static String get measurementId => EnvLoader.getRequired('MEASUREMENT_ID');

  // 🗂️ Google Drive Configuration
  static String get googleApiKey =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_API_KEY');
  static String get googleClientId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_CLIENT_ID');
  static String get googleDriveFolderId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_DRIVE_FOLDER_ID');

  // Carpetas específicas para proyectos
  static String get googleDriveProjectsLogoFolderId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_DRIVE_PROJECTS_LOGO_FOLDER_ID');
  static String get googleDriveProjectsMobileFolderId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_DRIVE_PROJECTS_MOBILE_FOLDER_ID');
  static String get googleDriveProjectsWebFolderId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_DRIVE_PROJECTS_WEB_FOLDER_ID');

  // Carpeta específica para certificaciones
  static String get googleDriveCertificationsFolderId =>
      EnvLoader.getRequired('REACT_APP_GOOGLE_DRIVE_CERTIFICATIONS_FOLDER_ID');

  //  Validación de configuración

  /// Verifica que todas las variables de Firebase estén configuradas
  static bool validateConfig() {
    try {
      // Validar solo Firebase (variables requeridas)
      apiKey;
      authDomain;
      databaseUrl;
      projectId;
      storageBucket;
      messagingSenderId;
      appId;
      measurementId;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un reporte de configuración (para debugging)
  static Map<String, String> getConfigReport() {
    return {
      '🔥 Firebase Project': projectId,
      '🌍 Auth Domain': authDomain,
      '📦 Storage Bucket': storageBucket,
    };
  }

  // 🔐 Configuración de permisos y seguridad

  /// Obtiene la configuración de permisos por defecto para nuevos usuarios
  /// Retorna true si los nuevos usuarios deben tener acceso automático
  /// Retorna false si requieren aprobación manual (recomendado)
  static bool get defaultUserPermission =>
      EnvLoader.getBool('DEFAULT_USER_PERMISSION', defaultValue: false);

  /// Obtiene el tiempo de expiración de sesión en minutos
  static int get sessionTimeout =>
      EnvLoader.getInt('SESSION_TIMEOUT_MINUTES', defaultValue: 60);

  /// Verifica si el modo de desarrollo está activo
  static bool get isDevelopmentMode =>
      EnvLoader.getBool('DEVELOPMENT_MODE', defaultValue: false);

  /// Verifica si se debe registrar actividad del usuario
  static bool get logUserActivity =>
      EnvLoader.getBool('LOG_USER_ACTIVITY', defaultValue: true);
}
