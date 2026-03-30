import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'services/app_config.dart';

/// 🔥 Firebase configuration options - Cargadas desde AppConfig (.env)
/// Las credenciales se cargan dinámicamente desde variables de entorno
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Construir FirebaseOptions dinámicamente desde AppConfig
    return FirebaseOptions(
      apiKey: AppConfig.apiKey,
      appId: AppConfig.appId,
      messagingSenderId: AppConfig.messagingSenderId,
      projectId: AppConfig.projectId,
      authDomain: AppConfig.authDomain,
      databaseURL: AppConfig.databaseUrl,
      storageBucket: AppConfig.storageBucket,
    );
  }
}

