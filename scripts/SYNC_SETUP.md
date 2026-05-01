# 🔄 Sincronización de Certificaciones Drive → Firebase

Este script sincroniza automáticamente los archivos de certificaciones desde tu carpeta de Google Drive a Firebase Realtime Database.

## ⚙️ Configuración

### 1. Obtener Service Account de Google

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto
3. Ve a **Credenciales** → **Crear credencial** → **Service Account**
4. Crea una clave JSON
5. Descarga el archivo JSON

### 2. Habilitar API de Google Drive

En Google Cloud Console:

- Ve a **APIs y servicios** → **Biblioteca**
- Busca "Google Drive API"
- Haz clic en **Habilitar**

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Google Cloud Service Account
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Firebase
FIREBASE_DATABASE_URL=https://tu-proyecto.firebaseio.com

# Google Drive
REACT_APP_GOOGLE_DRIVE_FOLDER_ID=1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI
```

## 📦 Instalación

```bash
# Instalar dependencias
npm install

# O si usas el script de desarrollo:
npm run setup
```

## 🚀 Uso

### Sincronización manual

```bash
# Ejecutar desde la raíz del proyecto
node scripts/sync-certifications.js

# O con npm script (si lo agregaste a package.json)
npm run sync:certs
```

### Sincronización automática (Cloud Functions)

El mismo script puede ejecutarse como Cloud Function:

```bash
# Desplegar a Firebase Cloud Functions
firebase deploy --only functions:syncCertifications
```

### Sincronización periódica (Cron)

En tu servidor o máquina local:

```bash
# Linux/Mac: agregar a crontab (ejecutar cada hora)
0 * * * * cd /path/to/cv_anth && node scripts/sync-certifications.js

# O cada día a las 2 AM
0 2 * * * cd /path/to/cv_anth && node scripts/sync-certifications.js
```

## 📊 Estructura de datos en Firebase

Después de sincronizar, tus certificaciones en Firebase tendrán esta estructura:

```json
{
  "Certifications": {
    "cert_001": {
      "name": "AWS Solutions Architect",
      "driveFileId": "1abc...xyz",
      "description": "Sincronizado desde Google Drive - 01/05/2026",
      "createdAt": 1714521600000
    }
  }
}
```

## 🔧 Personalización

### Cambiar formato de nombre de certificación

En `scripts/sync-certifications.js`, modifica la función `extractCertName()`:

```javascript
// Ejemplo: mantener extensiones
function extractCertName(fileName) {
  return fileName.replace(/_/g, " ");
}
```

### Agregar descripción desde el nombre

```javascript
const certData = {
  name: certName,
  driveFileId: fileId,
  description: `Obtenido de: ${fileName}`, // ← personaliza aquí
  createdAt: Date.now(),
};
```

## ⚠️ Solución de problemas

### Error: "GOOGLE_APPLICATION_CREDENTIALS not found"

```bash
# Verifica que el archivo existe
ls -la /path/to/service-account.json

# O copia el archivo al proyecto
cp ~/Downloads/service-account.json scripts/
# Luego actualiza .env: GOOGLE_APPLICATION_CREDENTIALS=scripts/service-account.json
```

### Error: "REACT_APP_GOOGLE_DRIVE_FOLDER_ID not configured"

- Verifica que el ID esté en `.env`
- Usa este formato: `REACT_APP_GOOGLE_DRIVE_FOLDER_ID=1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI`

### La sincronización no crea certificaciones

1. Verifica que hay archivos en la carpeta de Drive
2. Comprueba que Firebase está correctamente configurada
3. Mira los logs del script para detalles

```bash
# Ejecutar con logs detallados
DEBUG=* node scripts/sync-certifications.js
```

## 🔐 Seguridad

- **Nunca** commits el archivo `service-account.json` a git
- Agrega a `.gitignore`:

```gitignore
service-account.json
.env
.env.local
```

- El service account solo necesita permisos de lectura en Drive

## 📱 Uso desde la app Flutter

También puedes agregar un botón en la app para sincronizar manualmente:

```dart
// En tu controlador
Future<void> syncCertificationsFromDrive() async {
  // Esta función ejecutaría el script en tu backend
  // o una Cloud Function
}
```

---

**Preguntas o problemas?** Revisa los logs del script para más detalles.
