# 🔧 Solución: Error de Autenticación con Google Drive

## ❌ Problema

"Autenticación cancelada. Necesitas autorizar el acceso a Google Drive para subir imágenes."

## ✅ Soluciones

### 1. Configurar Google Cloud Console

#### a) Verificar URIs de redirección autorizados

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto: `portafolio-81169`
3. Ve a **APIs & Services** → **Credentials**
4. Haz clic en tu OAuth 2.0 Client ID: `13135437716-in66mnai5c70lemcigrkg8dtvud1m3kr.apps.googleusercontent.com`
5. En **Authorized JavaScript origins**, agrega:

   ```bash
   http://localhost:50000
   http://localhost:8080
   https://18-anth.github.io
   ```

6. En **Authorized redirect URIs**, agrega:

   ```bash
   http://localhost:50000/
   http://localhost:8080/
   https://18-anth.github.io/CV_Anth_/
   ```

#### b) Verificar APIs habilitadas

En **APIs & Services** → **Library**, busca y habilita:

- ✅ Google Drive API
- ✅ Google Sign-In API

#### c) Verificar scopes permitidos

En **OAuth consent screen**, verifica que los scopes incluyan:

- `https://www.googleapis.com/auth/drive.file`
- `email`
- `profile`

### 2. Verificar que no hay bloqueadores de popup

El navegador puede estar bloqueando el popup de Google Sign-In:

- ✅ Verifica que no hay bloqueador de popups activo
- ✅ Permite popups para tu dominio
- ✅ En Chrome: Verifica el ícono de popup bloqueado en la barra de direcciones

### 3. Limpiar caché y cookies

A veces los datos antiguos causan problemas:

```bash
# En Chrome DevTools
# Application → Storage → Clear site data
```

O en el código:

```bash
# Limpiar Flutter
flutter clean
flutter pub get

# Ejecutar de nuevo
flutter run -d chrome
```

### 4. Probar en modo incógnito

Esto elimina extensiones y caché:

- Abre una ventana de incógnito
- Navega a tu app
- Intenta subir un proyecto

### 5. Verificar que el popup no se cierra automáticamente

El usuario debe:

1. Hacer clic en "Subir Proyecto"
2. **NO cerrar** el popup de Google
3. Seleccionar cuenta de Google
4. Hacer clic en "Permitir"
5. Esperar a que se cierre automáticamente

## 🎯 Mejoras recomendadas

### Agregar instrucciones visuales

Mostrar un diálogo antes de abrir el popup:

```dart
// Antes de llamar a preAuthenticate()
await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Autorización necesaria'),
    content: const Text(
      'Se abrirá una ventana de Google.\n\n'
      '✅ Selecciona tu cuenta\n'
      '✅ Haz clic en "Permitir"\n'
      '❌ NO cierres la ventana',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Entendido'),
      ),
    ],
  ),
);
```

### Reintentar autenticación

Dar opción de reintentar si falla:

```dart
bool authenticated = false;
int retries = 0;

while (!authenticated && retries < 3) {
  authenticated = await GoogleDriveUploadService.preAuthenticate();
  if (!authenticated) {
    retries++;
    // Mostrar diálogo de reintento
  }
}
```

## 📝 Checklist de verificación

- [ ] URIs de redirección configurados en Google Cloud Console
- [ ] APIs habilitadas (Google Drive API)
- [ ] Bloqueador de popups desactivado
- [ ] Caché limpiado
- [ ] Probado en modo incógnito
- [ ] Seguir las instrucciones del popup sin cerrarlo

## 🆘 Si nada funciona

### Opción 1: Usar autenticación persistente

Guardar el token de autenticación para no pedir permisos cada vez:

```dart
// En google_drive_upload_service.dart
static Future<void> _ensureAuthenticated() async {
  // Intentar autenticación silenciosa primero
  account = await googleSignIn.signInSilently(suppressErrors: false);

  // Solo mostrar popup si es necesario
  if (account == null) {
    account = await googleSignIn.signIn();
  }
}
```

### Opción 2: Usar Firebase Storage en lugar de Google Drive

Si Google Drive sigue dando problemas, usa Firebase Storage:

```dart
// Cambiar en UploadProject.dart
import 'package:firebase_storage/firebase_storage.dart';

final storageRef = FirebaseStorage.instance.ref();
final fileRef = storageRef.child('projects/$projectId/web/${file.name}');
await fileRef.putData(bytes);
final url = await fileRef.getDownloadURL();
```

## 🔗 Enlaces útiles

- [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
- [Google Sign-In para Web](https://developers.google.com/identity/sign-in/web/sign-in)
- [Troubleshooting Google Sign-In](https://developers.google.com/identity/sign-in/web/troubleshooting)
