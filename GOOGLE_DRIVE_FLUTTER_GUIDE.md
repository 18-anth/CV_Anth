# Google Drive en Flutter - Guía de Implementación

## Estructura de Carpetas en Google Drive

Cada certificación tiene su propia carpeta con la siguiente estructura:

```
certificacion-{uuid}/
├── logos/
│   ├── platform_logo.png
│   └── institution_logo.png
├── pdf/
│   └── certificate.pdf
└── images/
    ├── image1.jpg
    ├── image2.jpg
    └── image3.jpg
```

## URLs de Google Drive

### Formatos Soportados

#### 1. **Imágenes y Logos** (lh3.googleusercontent.com)
```
https://lh3.googleusercontent.com/d/{FILE_ID}
```
- ✅ Sin CORS
- ✅ Acceso directo sin autenticación (si archivo es público)
- ✅ Funciona en Image.network() sin configuración adicional

#### 2. **PDFs** (formato preview)
```
https://drive.google.com/file/d/{FILE_ID}/preview
```
- ✅ Visualización inline (no descarga)
- ✅ Compatible con WebViewWidget
- ✅ Funciona en web y móvil

#### 3. **Formato Legacy** (no recomendado)
```
https://drive.usercontent.google.com/download?id={FILE_ID}&export=view
```
- ⚠️ Puede tener problemas de CORS
- ⚠️ Puede forzar descarga en lugar de visualización

## Implementación en Flutter

### 1. Conversión de URLs (_fixGoogleDriveUrl)

```dart
/// Convierte URLs de Google Drive al formato correcto que evita CORS
/// Usa lh3.googleusercontent.com que permite acceso directo sin CORS
String _fixGoogleDriveUrl(String url) {
  if (url.isEmpty) return url;

  // Si ya es el formato correcto, devolverla sin cambios
  if (url.contains('lh3.googleusercontent.com/d/')) {
    return url;
  }

  // Extraer el ID del archivo de diferentes formatos
  RegExp regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
  Match? match = regExp.firstMatch(url);

  if (match != null && match.groupCount > 0) {
    String fileId = match.group(1)!;
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }

  return url;
}
```

**Casos de uso:**
- ✅ `https://drive.usercontent.google.com/download?id=ABC123` → `https://lh3.googleusercontent.com/d/ABC123`
- ✅ `https://drive.google.com/file/d/ABC123/view` → `https://lh3.googleusercontent.com/d/ABC123`
- ✅ `https://www.googleapis.com/drive/v3/files/ABC123` → `https://lh3.googleusercontent.com/d/ABC123`

### 2. Visualización de PDFs

```dart
Widget _buildPdfOrImageViewer(String url) {
  // En web, usar iframe
  if (kIsWeb) {
    final viewId = 'cert-iframe-${url.hashCode}';
    return buildWebPdfViewerWidget(url, viewId);
  }

  final isPdf = url.toLowerCase().endsWith('.pdf') ||
                url.contains('drive.google.com') ||
                url.contains('docs.google.com');

  if (isPdf) {
    // Convertir a formato /preview para visualización inline
    String pdfUrl = url;
    if (url.contains('drive.google.com') || 
        url.contains('drive.usercontent.google.com')) {
      RegExp regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
      Match? match = regExp.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        String fileId = match.group(1)!;
        pdfUrl = 'https://drive.google.com/file/d/$fileId/preview';
      }
    }
    
    return SizedBox(
      height: 800,
      child: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(pdfUrl)),
      ),
    );
  } else {
    // Es una imagen
    return Image.network(url, fit: BoxFit.cover);
  }
}
```

### 3. Visualización de Logos

```dart
// Platform Logo
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AppColors.grey.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      _fixGoogleDriveUrl(platformLogoUrl),  // ✅ Usar conversión
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.school_rounded,
          size: 40,
          color: AppColors.grey,
        );
      },
    ),
  ),
)
```

### 4. Galería de Imágenes

```dart
Widget _buildImageCard(String imageUrl, int imageNumber) {
  return GestureDetector(
    onTap: () => _showImageDialog(imageUrl),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _fixGoogleDriveUrl(imageUrl),  // ✅ Usar conversión
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.light5,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.black,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.light5,
              child: const Icon(
                Icons.broken_image,
                size: 48,
                color: AppColors.darkgrey,
              ),
            );
          },
        ),
      ),
    ),
  );
}
```

## Modelo de Datos en Firebase

```json
{
  "id": "cert-001",
  "name": "Certificación AWS Solutions Architect",
  "description": "Certificación profesional de AWS",
  "series": "SAA-C03",
  "link": "https://aws.amazon.com/certification/",
  
  // Logos (URLs directas con FILE_ID)
  "platformLogoUrl": "https://lh3.googleusercontent.com/d/1ABC123",
  "institutionLogoUrl": "https://lh3.googleusercontent.com/d/1XYZ789",
  
  // PDF (puede ser URL directa o solo el ID)
  "pdfUrl": "https://drive.google.com/file/d/1PDF456/view",
  "driveFileId": "1PDF456",  // Alternativa: solo el ID
  
  // Galería de imágenes
  "images": [
    "https://lh3.googleusercontent.com/d/1IMG001",
    "https://lh3.googleusercontent.com/d/1IMG002",
    "https://lh3.googleusercontent.com/d/1IMG003"
  ]
}
```

## Servicios Necesarios

### GoogleDriveService (ya implementado)

```dart
class GoogleDriveService {
  /// Construye URL de previsualización para PDFs
  static String previewUrl(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }
  
  /// Construye URL de descarga directa
  static String downloadUrl(String fileId) {
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }
  
  /// Construye URL de thumbnail
  static String thumbnailUrl(String fileId) {
    return 'https://drive.google.com/thumbnail?id=$fileId&sz=w200';
  }
}
```

## Comparación con React

| Aspecto | React (tu código) | Flutter (implementado) |
|---------|-------------------|------------------------|
| **Autenticación** | Google Identity Services | No necesario (archivos públicos) |
| **Upload** | Drive API v3 con OAuth | No implementado (solo lectura) |
| **Permisos** | anyone → reader | Archivos ya públicos |
| **URLs Imágenes** | `lh3.googleusercontent.com/d/{ID}` | ✅ Mismo formato |
| **URLs PDFs** | `drive.google.com/file/d/{ID}/preview` | ✅ Mismo formato |
| **Conversión URL** | `convertGoogleDriveUrl()` | ✅ `_fixGoogleDriveUrl()` |
| **CORS** | Resuelto con lh3 | ✅ Resuelto con lh3 |

## Diferencias Clave

### React (Upload + Visualización)
- ✅ OAuth2 para subir archivos
- ✅ API de Google Drive v3
- ✅ Gestión de permisos públicos
- ✅ Upload multipart

### Flutter (Solo Visualización)
- ✅ No requiere autenticación (archivos públicos)
- ✅ URLs directas desde Firebase
- ✅ Conversión automática de URLs legacy
- ⚠️ No sube archivos (solo lee)

## Próximos Pasos (Opcional)

Si necesitas **subir archivos desde Flutter**:

1. **Agregar dependencia:**
   ```yaml
   dependencies:
     google_sign_in: ^6.0.0
     googleapis: ^11.0.0
   ```

2. **Implementar OAuth2:**
   ```dart
   // Similar al flujo de React
   // requestGoogleAccessToken()
   ```

3. **Crear servicio de upload:**
   ```dart
   class GoogleDriveUploadService {
     Future<String> uploadFile(File file, String folderId) async {
       // Multipart upload similar a React
     }
   }
   ```

## Recursos

- [Google Drive API](https://developers.google.com/drive/api/v3/reference)
- [Direct Link Format](https://developers.google.com/drive/api/guides/manage-sharing)
- [webview_flutter](https://pub.dev/packages/webview_flutter)
- [url_launcher](https://pub.dev/packages/url_launcher)

---

**Última actualización:** 2 de mayo de 2026
