# 🔥 Configuración de Firebase Authentication

## ❌ Error: "La operación no está permitida"

Este error ocurre cuando el método de autenticación **Email/Password** no está habilitado en Firebase Console.

## ✅ Solución Paso a Paso

### 1. Accede a Firebase Console
- Ve a: https://console.firebase.google.com
- Inicia sesión con tu cuenta de Google

### 2. Selecciona tu Proyecto
- Busca y selecciona tu proyecto (probablemente se llama algo relacionado con `cv_anth`)

### 3. Habilita Email/Password Authentication

#### En el menú lateral izquierdo:
1. Haz clic en **"Authentication"** (🔐 icono de candado)
2. Si es la primera vez, haz clic en **"Get Started"** o **"Comenzar"**
3. Ve a la pestaña **"Sign-in method"** (Método de inicio de sesión)

#### Habilitar Email/Password:
1. En la lista de proveedores, busca **"Email/Password"**
2. Haz clic en el proveedor
3. Activa el interruptor **"Enable"** (Habilitar)
4. **NO necesitas** habilitar "Email link (passwordless sign-in)"
5. Haz clic en **"Save"** (Guardar)

### 4. Verifica la Configuración
- El proveedor "Email/Password" debería aparecer como **"Enabled"** (Habilitado)
- Estado debe ser: ✅ **Enabled**

## 🧪 Prueba el Login

Después de habilitar el método de autenticación:

1. Recarga tu aplicación Flutter
2. Intenta hacer login o registrarte
3. El error "La operación no está permitida" debería desaparecer

## 🔍 Otros Errores Comunes

### "user-not-found" / "wrong-password"
- **Causa**: Las credenciales son incorrectas
- **Solución**: Verifica el email y contraseña

### "email-already-in-use"
- **Causa**: El email ya está registrado
- **Solución**: Usa otro email o intenta hacer login

### "weak-password"
- **Causa**: La contraseña tiene menos de 6 caracteres
- **Solución**: Usa una contraseña de al menos 6 caracteres

### "network-request-failed"
- **Causa**: Sin conexión a internet
- **Solución**: Verifica tu conexión

### "too-many-requests"
- **Causa**: Demasiados intentos fallidos
- **Solución**: Espera unos minutos antes de intentar de nuevo

## 📝 Crear un Usuario de Prueba

### Opción 1: Desde la App
1. Abre el diálogo de login en tu app
2. Haz clic en "Registrarse con un nuevo email"
3. Ingresa un email válido (ej: `test@example.com`)
4. Ingresa una contraseña de al menos 6 caracteres
5. El usuario se creará automáticamente en Firebase

### Opción 2: Desde Firebase Console
1. Ve a Authentication → Users
2. Haz clic en "Add user"
3. Ingresa email y contraseña
4. Haz clic en "Add user"

## 🔐 Buenas Prácticas de Seguridad

- ✅ Usa contraseñas de al menos 8 caracteres
- ✅ Combina mayúsculas, minúsculas, números y símbolos
- ✅ No compartas tus credenciales
- ✅ Usa emails únicos para cada usuario

## 🆘 Soporte

Si sigues teniendo problemas:
1. Verifica que Firebase esté inicializado correctamente en `main.dart`
2. Revisa la consola del navegador/terminal para ver logs de error
3. Verifica que las variables de entorno estén configuradas correctamente
4. Asegúrate de tener conexión a internet

## 📚 Documentación Oficial

- [Firebase Authentication - Email/Password](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Firebase Console](https://console.firebase.google.com)
