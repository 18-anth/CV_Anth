# 🔐 Sistema de Autenticación - CV Anthony

## 📋 Cambios Realizados

Se ha implementado un sistema completo de autenticación que:

✅ **Pantalla de Login** - Interfaz elegante con email y contraseña  
✅ **Protección de Rutas** - Solo usuarios autenticados pueden acceder al CV  
✅ **Gestión de Sesión** - Login, logout y manejo de estado global  
✅ **Interfaz Completa** - Acceso a todos los módulos (Home, Projects, Certifications, Contact, About)  
✅ **Edición de Información** - Los usuarios autenticados pueden editar su perfil  

## 🚀 Pasos para Ejecutar

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Ejecutar la Aplicación
```bash
flutter run
```

## 🔑 Credenciales de Prueba

### Email
```
admin@example.com
```

### Contraseña
```
password123
```

## 📁 Estructura de Archivos Nuevos/Modificados

```
lib/
├── controllers/
│   └── auth_controller.dart        # 🆕 Controlador de autenticación
├── models/
│   └── user_model.dart             # 🆕 Modelo de usuario
├── view/
│   └── Auth/
│       └── LoginScreen.dart        # 🆕 Pantalla de login
├── main.dart                       # ✏️ Actualizado con AuthController global
├── layouts/
│   └── main_layout.dart            # ✏️ Agregado botón de logout
└── routes/
    └── app_routes.dart             # ✏️ Rutas protegidas con autenticación
```

## 🎯 Flujo de Autenticación

1. **Usuario sin autenticar** → Ve la pantalla de **Login**
2. **Ingresa credenciales** → Sistema valida email y contraseña
3. **Login exitoso** → Redirige a la **pantalla Home**
4. **Usuario autenticado** → Acceso a todos los módulos:
   - 🏠 Home
   - 📁 Projects
   - 🎓 Certifications
   - 📧 Contact
   - 👤 About Me
5. **Click en "Salir"** → Logout y regreso a la pantalla de login

## 🛠️ Funcionalidades Principales

### AuthController
- `login(email, password)` - Autentica al usuario
- `logout()` - Cierra la sesión
- `isAuthenticated` - Estado de autenticación
- `userEmail` - Email del usuario autenticado

### Validaciones
- ✓ Email no vacío
- ✓ Formato válido de email (@)
- ✓ Contraseña mínimo 6 caracteres

### UI/UX
- Interfaz responsiva (móvil y desktop)
- Indicador de carga durante el login
- Mensajes de error detallados
- Botón de logout en AppBar y Drawer
- Diálogo de confirmación antes de logout

## 📝 Próximos Pasos (Opcional)

### Para implementar edición de perfil:
1. Crear un `EditProfileScreen`
2. Agregar formulario para editar información
3. Guardar cambios en Firebase Database
4. Mostrar datos guardados en las vistas correspondientes

### Para mejorar la seguridad:
1. Integrar autenticación real con Firebase Authentication
2. Implementar encriptación de contraseñas
3. Agregar recuperación de contraseña
4. Implementar verificación de email

### Para persistencia:
1. Guardar token de sesión localmente
2. Mantener sesión después de cerrar la app
3. Implementar refresco de token automático

## 💡 Notas

- Las credenciales actualmente son estáticas (para demostración)
- Para producción, conectar a Firebase Authentication
- El email se muestra en el drawer cuando está autenticado
- El sistema protege automáticamente todas las rutas

---

**¡Listo para usar!** 🎉

Ingresa con:
- Email: `admin@example.com`
- Contraseña: `password123`
