import '../services/google_drive_service.dart';

/// Utilidades para manejar URLs de Google Drive
class GoogleDriveUtils {
  /// Convierte URLs de Google Drive al formato con API key que funciona correctamente
  /// para leer archivos públicos sin problemas de CORS en Flutter Web.
  static String fixGoogleDriveUrl(String url) {
    if (url.isEmpty) return url;

    if (url.contains('alt=media')) return url;

    final regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);

    if (match != null && match.groupCount > 0) {
      final fileId = match.group(1)!;
      return GoogleDriveService.downloadUrl(fileId);
    }

    return url;
  }

  /// Extrae el ID del archivo de Google Drive usando regex simple
  static String? extractDriveFileId(String url) {
    if (url.isEmpty) return null;
    // Extrae file IDs de Google Drive (típicamente 25+ caracteres)
    final regex = RegExp(r'[-\w]{25,}');
    final match = regex.firstMatch(url);
    return match?.group(0);
  }

  /// Construye la URL correcta para imágenes de Google Drive
  /// Usa drive.google.com/uc?export=view que es estable y evita rate-limiting
  static String buildDriveImageUrl(String url) {
    final fileId = extractDriveFileId(url);
    if (fileId != null) {
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return url; // Si no es Drive, devolver la URL original
  }

  /// Construye la URL de descarga directa de Google Drive
  static String buildDriveDownloadUrl(String driveFileId) {
    return 'https://drive.google.com/uc?export=download&id=$driveFileId';
  }
}
