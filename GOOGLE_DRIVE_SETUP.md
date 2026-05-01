# 📤 Configuración de Google Drive para Proyectos

## 📁 Estructura de Almacenamiento

Las imágenes de los proyectos se almacenan en **Google Drive** organizadas en carpetas por proyecto:

```
Google Drive (Root Folder)
└── Projects/
    ├── {projectId-1}/
    │   ├── web/
    │   │   ├── 1234567890_screenshot1.png
    │   │   ├── 1234567891_screenshot2.jpg
    │   │   └── ...
    │   ├── mobile/
    │   │   ├── 1234567892_mobile1.png
    │   │   ├── 1234567893_mobile2.jpg
    │   │   └── ...
    │   └── logo/
    │       └── 1234567894_logo.png
    │
    ├── {projectId-2}/
    │   ├── web/
    │   ├── mobile/
    │   └── logo/
    └── ...
```

## 🔄 Flujo de Datos

1. **Flutter App** → Selecciona imágenes usando `file_picker`
2. **Flutter App** → Convierte imágenes a base64
3. **Flutter App** → Envía a Cloud Function `uploadProjectImage`
4. **Cloud Function** → Crea carpetas en Google Drive (si no existen)
5. **Cloud Function** → Sube imagen a Google Drive
6. **Cloud Function** → Hace la imagen pública
7. **Cloud Function** → Retorna URL de descarga
8. **Flutter App** → Guarda URLs en Firebase Realtime Database

### Datos en Firebase Realtime Database

```json
{
  "Projects": {
    "{projectId}": {
      "name": "Proyecto Ejemplo",
      "description": "Descripción del proyecto",
      "link": "https://ejemplo.com",
      "images": [
        "https://drive.google.com/uc?export=download&id=xxx",
        "https://drive.google.com/uc?export=download&id=yyy"
      ],
      "imagesMobile": [
        "https://drive.google.com/uc?export=download&id=zzz"
      ],
      "logo": "https://drive.google.com/uc?export=download&id=www",
      "timestamp": "2026-05-01T12:00:00.000Z"
    }
  }
}
```

## 🚀 Deploy de Cloud Function

### 1. Instalar dependencias

```bash
cd functions
npm install
```

### 2. Configurar variables de entorno

En Firebase Console → Functions → Configuration:

```bash
firebase functions:config:set google.drive_folder_id="YOUR_GOOGLE_DRIVE_FOLDER_ID"
```

O crear archivo `.env` en `/functions`:

```env
GOOGLE_DRIVE_FOLDER_ID=1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI
```

### 3. Desplegar la función

```bash
firebase deploy --only functions:uploadProjectImage
```

### 4. Verificar el deploy

La URL de la función será:
```
https://us-central1-portafolio-81169.cloudfunctions.net/uploadProjectImage
```

Esta URL ya está configurada en:
- `lib/services/google_drive_upload_service.dart`

## 🔐 Permisos y Autenticación

### Service Account

Firebase Functions usa automáticamente el **Service Account** de Firebase con permisos de Google Drive.

### Permisos necesarios:

- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`

### Carpeta raíz de Google Drive:

La carpeta raíz debe estar compartida con el Service Account:

1. Ir a Google Drive
2. Click derecho en la carpeta → Compartir
3. Agregar el email del Service Account:
   ```
   portafolio-81169@appspot.gserviceaccount.com
   ```
4. Dar permisos de **Editor**

## 📝 Archivos Modificados

### Nuevos archivos:

1. **`functions/upload-project-image.js`** - Cloud Function para subir imágenes
2. **`lib/services/google_drive_upload_service.dart`** - Servicio Flutter para llamar la función

### Archivos actualizados:

1. **`lib/services/firebase_service.dart`** - `generateUUID()` ahora es público
2. **`lib/view/Project/UploadProject.dart`** - Usa Google Drive en lugar de Firebase Storage
3. **`lib/view/Project/EditProject.dart`** - Usa Google Drive en lugar de Firebase Storage
4. **`pubspec.yaml`** - Agregada dependencia `http: ^1.1.0`

## ✅ Testing

### 1. Probar Cloud Function localmente:

```bash
cd functions
npm install -g firebase-tools
firebase emulators:start --only functions
```

### 2. Probar desde Flutter:

```dart
// En UploadProject.dart o EditProject.dart
// El código ya está configurado, solo ejecutar:
flutter run -d chrome
```

### 3. Verificar en Google Drive:

1. Ir a Google Drive
2. Navegar a `Projects/{projectId}/web` (o mobile/logo)
3. Verificar que las imágenes se subieron correctamente

### 4. Verificar en Firebase Database:

```bash
firebase database:get /Projects/{projectId}
```

O en Firebase Console → Realtime Database

## 🐛 Troubleshooting

### Error: "GOOGLE_DRIVE_FOLDER_ID no configurada"

**Solución:**
```bash
firebase functions:config:set google.drive_folder_id="YOUR_FOLDER_ID"
firebase deploy --only functions
```

### Error: "Failed to upload image"

**Verificar:**
1. Service Account tiene permisos en la carpeta
2. Carpeta raíz existe y es accesible
3. La imagen no excede 10MB (límite de Cloud Functions)

### Error: "Access-Control-Allow-Origin"

**Solución:** Ya está configurado CORS en la Cloud Function. Verificar que el request incluye headers correctos.

### Imágenes no se ven

**Verificar:**
1. Las imágenes son públicas (la Cloud Function las hace públicas automáticamente)
2. La URL es correcta: `https://drive.google.com/uc?export=download&id={fileId}`
3. El fileId es válido

## 📊 Límites y Consideraciones

### Cloud Functions:

- **Timeout:** 540 segundos (9 minutos)
- **Memory:** 1GB
- **Max request size:** 10MB por imagen

### Google Drive API:

- **Quota:** 20,000 requests/día (gratis)
- **Upload size:** Sin límite por archivo
- **Storage:** 15GB gratis

### Recomendaciones:

- Optimizar imágenes antes de subir (usar compresión)
- Limitar número de imágenes por proyecto (10-20)
- Considerar usar thumbnails para previews

## 🔄 Migración desde Firebase Storage

Si ya tienes imágenes en Firebase Storage:

1. Las URLs antiguas seguirán funcionando
2. Nuevas imágenes se guardarán en Google Drive
3. Opcionalmente, puedes migrar imágenes antiguas manualmente

## 📚 Referencias

- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Google Drive API](https://developers.google.com/drive/api/v3/about-sdk)
- [Service Accounts](https://cloud.google.com/iam/docs/service-accounts)
