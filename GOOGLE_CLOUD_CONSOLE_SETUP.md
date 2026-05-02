# 🔧 Configuración de Google Cloud Console

## ❌ Error Actual

```bash
Error 400: redirect_uri_mismatch
origin=http://localhost:62928
```

Este error indica que el origen de tu aplicación **NO está autorizado** en las credenciales de OAuth 2.0.

## ✅ Solución: Configurar Orígenes Autorizados

### 1. Ir a Google Cloud Console

1. Abre [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a **APIs & Services** → **Credentials**

### 2. Editar OAuth 2.0 Client ID

1. Busca tu **OAuth 2.0 Client ID** (tipo: Web application)
2. Haz clic en el icono de **editar** (lápiz)

### 3. Agregar Orígenes de JavaScript Autorizados

En la sección **"Authorized JavaScript origins"**, agrega estas URLs:

#### Para Desarrollo Local (localhost)

```bash
http://localhost
http://localhost:8080
http://localhost:62928
```

> **Nota:** Flutter Web usa puertos aleatorios (como 62928). Agregar `http://localhost` sin puerto específico permite **cualquier puerto**.

#### Para Producción (GitHub Pages)

```bash
https://18-anth.github.io
```

#### Para Otros Entornos (Opcional)

```bash
http://127.0.0.1
https://tu-dominio-personalizado.com
```

### 4. ❌ NO necesitas "Authorized redirect URIs"

**IMPORTANTE:** El flujo de `initTokenClient` (OAuth2 implicit flow) **NO usa redirect URIs**.

Solo configura los **"Authorized JavaScript origins"**.

### 5. Guardar Cambios

1. Haz clic en **"Save"** al final de la página
2. Espera unos segundos para que los cambios se propaguen

## 🧪 Verificar la Configuración

### Ejemplo de Configuración Correcta

```bash
OAuth 2.0 Client ID
------------------------------
Name: CV Anth Web Client
Client ID: 13135437716-in66mnai5c70lemcigrkg8dtvud1m3kr.apps.googleusercontent.com

Authorized JavaScript origins:
  • http://localhost
  • https://18-anth.github.io

Authorized redirect URIs:
  (vacío o con redirects para otros flujos)
```

## 🚀 Probar la Aplicación

### 1. Reiniciar la aplicación

```bash
# Detener la app actual (Ctrl+C)
flutter clean
flutter pub get
flutter run -d chrome
```

### 2. Probar autenticación

1. Navega a la sección de **Upload Project**
2. Haz clic en **"Autenticar con Google"**
3. Debe abrir el popup de Google **sin errores**
4. Selecciona tu cuenta
5. Acepta los permisos (Drive File scope)
6. Debe cerrar el popup y autenticarte correctamente

### 3. Probar en GitHub Pages

Después de deployar:

1. Visita `https://18-anth.github.io/CV_Anth_/`
2. Prueba la autenticación
3. Debe funcionar **igual** que en localhost

## 📋 Checklist de Configuración

- [ ] OAuth 2.0 Client ID creado (tipo: Web application)
- [ ] `http://localhost` agregado a "Authorized JavaScript origins"
- [ ] `https://18-anth.github.io` agregado a "Authorized JavaScript origins"
- [ ] **NO hay** redirect URIs configuradas (o están vacías)
- [ ] Cambios guardados en Google Cloud Console
- [ ] App reiniciada después de la configuración
- [ ] Popup de Google se abre correctamente
- [ ] Token de acceso se recibe sin errores

## 🔍 Troubleshooting

### Error: "Access blocked: This app's request is invalid"

**Causa:** El origen no está autorizado o los cambios no se han propagado.

**Solución:**

1. Verificar que agregaste **http://localhost** (sin puerto)
2. Esperar 1-2 minutos para propagación
3. Limpiar caché del navegador: `Ctrl+Shift+Delete`
4. Recargar la página: `Ctrl+F5`

### Error: "idpiframe_initialization_failed"

**Causa:** El dominio no está autorizado o hay problemas de CORS.

**Solución:**

1. Agregar el dominio correcto a los orígenes autorizados
2. Asegurarse de usar **HTTPS** en producción
3. No usar `file://` protocol (no funciona con OAuth)

### El popup no se abre

**Causa:** Bloqueadores de popups del navegador.

**Solución:**

1. Permitir popups para tu dominio
2. Verificar que `requestAccessToken()` se llama desde una **acción del usuario** (click)

## 📚 Referencias

- [Google Identity Services - Web](https://developers.google.com/identity/gsi/web/guides/overview)
- [OAuth 2.0 for Client-side Web Applications](https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow)
- [Google Cloud Console](https://console.cloud.google.com/)

## 🎯 Resultado Esperado

Después de configurar correctamente:

✅ Popup de Google se abre sin errores  
✅ Usuario puede autenticarse  
✅ Access token se recibe correctamente  
✅ Archivos se pueden subir a Google Drive  
✅ Funciona tanto en localhost como en GitHub Pages

---

**⚠️ Importante:** Nunca compartas tu **Client Secret** públicamente. El **Client ID** es público y está bien usarlo en código frontend.
