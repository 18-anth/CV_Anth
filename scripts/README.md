# 🔄 Sistema de Sincronización: Google Drive → Firebase

Este sistema sincroniza automáticamente tus certificaciones desde Google Drive a Firebase.

## 📋 ¿Cómo funciona?

```
Tu cuenta Drive                  Google Drive API           Firebase Realtime DB          Tu app Flutter
(Carpeta de certs) ────────────→ (listar archivos) ────────→ (guardar/actualizar) ────→ (mostrar certs)
   1yT6iFdqcfY-6...              lista con fileIds          Nodo "Certifications"        CertificationDetail
```

## 🚀 Opciones de Sincronización

### Opción 1️⃣: Sincronización Manual (Script Local)

Ejecuta manualmente cuando agregues nuevas certificaciones:

```bash
# Instalar dependencias (solo una vez)
npm install

# Copiar archivo .env
cp .env.sync.example .env.sync

# Editar .env.sync con tus valores
nano .env.sync

# Sincronizar
node scripts/sync-certifications.js
```

**Ventajas:**
- ✅ Control total
- ✅ Sin costo adicional
- ✅ Fácil de debuggear

**Ideal para:** Desarrollo local, sincronización ocasional

---

### Opción 2️⃣: Cloud Function Automática (Cada hora)

Sincroniza automáticamente cada hora sin intervención:

```bash
# 1. Instalar Firebase CLI
npm install -g firebase-tools

# 2. Autenticarse
firebase login

# 3. Configurar variables de entorno en Cloud Functions
firebase functions:config:set \
  googleapi.drive_folder_id="1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI"

# 4. Desplegar función
firebase deploy --only functions:syncCertificationsScheduled

# 5. Crear scheduler en Cloud Console (o automático)
```

**Ventajas:**
- ✅ Completamente automático
- ✅ Se ejecuta cada hora
- ✅ Logs en Cloud Console
- ✅ Sin mantener servidor

**Costo:** ~$0 (con free tier de Google Cloud)

**Ideal para:** Producción, sincronización automática continua

---

### Opción 3️⃣: Cron Job en tu servidor

Ejecuta el script en tu servidor cada X horas:

```bash
# Linux/Mac: Editar crontab
crontab -e

# Agregar (ejecutar cada hora a minuto 0)
0 * * * * cd /ruta/proyecto && node scripts/sync-certifications.js >> sync.log 2>&1

# Agregar (ejecutar cada día a las 2 AM)
0 2 * * * cd /ruta/proyecto && node scripts/sync-certifications.js >> sync.log 2>&1
```

**Ventajas:**
- ✅ Control total del schedule
- ✅ Logs locales
- ✅ Funciona offline

**Ideal para:** Si tienes servidor propio

---

## 📝 Ejemplo: Flujo Completo

### Paso 1: Agregar nueva certificación a Drive

Subes un archivo a tu carpeta de Drive:
```
📁 Carpeta de Certificaciones
  └── AWS_Solutions_Architect.pdf
```

### Paso 2: Sincronizar (Opción 1, 2 o 3)

```bash
node scripts/sync-certifications.js
```

### Paso 3: Firebase se actualiza automáticamente

```json
{
  "Certifications": {
    "abc123xyz": {
      "name": "AWS Solutions Architect",
      "driveFileId": "1xyz...abc",
      "description": "Sincronizado desde Google Drive - 01/05/2026",
      "createdAt": 1714521600000
    }
  }
}
```

### Paso 4: Tu app muestra la certificación

La app Flutter lee automáticamente:

```
CertificationsList
├── AWS Solutions Architect (nuevo ✨)
└── Google Cloud Associate
```

---

## 🔧 Configuración Rápida

### Para Opción 1 (Local):

```bash
# 1. Copiar archivo de ejemplo
cp .env.sync.example .env.sync

# 2. Editar con tus valores
# GOOGLE_APPLICATION_CREDENTIALS=ruta/a/service-account.json
# FIREBASE_DATABASE_URL=https://tu-proyecto.firebaseio.com
# REACT_APP_GOOGLE_DRIVE_FOLDER_ID=1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI

# 3. Instalar dependencias
npm install

# 4. Probar sincronización
node scripts/sync-certifications.js
```

### Para Opción 2 (Cloud Function):

```bash
# En functions/
cd functions
npm install

# Configurar variables
firebase functions:config:set googleapi.drive_folder_id="1yT6..."

# Desplegar
firebase deploy --only functions
```

---

## 📱 Usar en tu app Flutter

Ya está listo. Tu app muestra automáticamente las certificaciones sincronizadas:

```dart
class CertificationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirebaseService.fetchCertifications(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: [
              for (final cert in snapshot.data!)
                ListTile(
                  title: Text(cert['name']),
                  subtitle: Text(cert['description']),
                  onTap: () {
                    context.push('/certification/${cert['id']}');
                  },
                ),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

---

## ❓ Preguntas Frecuentes

**P: ¿Qué archivos soporta?**
R: Cualquier archivo (PDF, PNG, JPG, etc.). El nombre se convierte en nombre de certificación.

**P: ¿Se duplican si sincronizo varias veces?**
R: No, detecta duplicados por `driveFileId`.

**P: ¿Se borran certificaciones si las elimino de Drive?**
R: No, la sincronización solo agrega/actualiza. Para borrar, hazlo en Firebase manualmente.

**P: ¿Cómo cambio el formato del nombre?**
R: Edita la función `extractCertName()` en el script.

**P: ¿Puedo sincronizar múltiples carpetas?**
R: Sí, crea otro script con un `GOOGLE_DRIVE_FOLDER_ID` diferente.

---

## 🔐 Seguridad

- 🔒 Never commit `service-account.json` a Git
- 🔒 Las variables de entorno son privadas
- 🔒 El service account solo lee de Drive (permisos mínimos)

**Archivo `.gitignore`:**
```gitignore
service-account.json
.env.sync
.env.sync.local
```

---

## 📚 Archivos del Sistema

```
scripts/
├── sync-certifications.js      ← Script Node.js para sincronizar manualmente
├── SYNC_SETUP.md              ← Documentación detallada de configuración
└── README.md                  ← Este archivo

functions/
└── sync-certifications.js      ← Cloud Function (automática cada hora)

.env.sync.example              ← Plantilla de variables de entorno
```

---

## 🆘 Solución de Problemas

```bash
# Ver logs del script
node scripts/sync-certifications.js 2>&1 | tee sync.log

# Ver logs de Cloud Function
firebase functions:log

# Debuggear conexión a Firebase
DEBUG=* node scripts/sync-certifications.js

# Verificar que el archivo .env.sync existe
ls -la .env.sync
```

---

**¿Listo?** Elige tu opción favorita y comienza a sincronizar. 🚀
