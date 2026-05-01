# 📤 Módulo de Upload Project

## 🎯 Descripción

Módulo completo para subir proyectos con imágenes a Firebase Realtime Database y Firebase Storage. Permite a usuarios autenticados crear proyectos con:

- ✅ Nombre del proyecto
- ✅ Descripción detallada
- ✅ Link del proyecto
- ✅ Imágenes para Web (múltiples)
- ✅ Imágenes para Mobile (múltiples)

## 📁 Archivos Creados

### 1. Servicios

#### `/lib/services/firebase_storage_service.dart`
Servicio para subir imágenes a Firebase Storage:
- `uploadImage()` - Sube una imagen individual
- `uploadMultipleImages()` - Sube múltiples imágenes con progreso
- `deleteImage()` - Elimina una imagen
- `deleteMultipleImages()` - Elimina múltiples imágenes

#### Extensión de `/lib/services/firebase_service.dart`
Métodos agregados para proyectos:
- `saveProject()` - Guarda un proyecto en Firebase Realtime Database
- `deleteProject()` - Elimina un proyecto

### 2. Vista

#### `/lib/view/Project/UploadProject.dart`
Pantalla completa de formulario para subir proyectos con:
- Formulario con validación
- Selector de imágenes (Web y Mobile)
- Vista previa de imágenes seleccionadas
- Barra de progreso durante la subida
- Protección con autenticación (solo usuarios autenticados)

### 3. Rutas

Actualizado `/lib/routes/app_routes.dart`:
- Agregado import de `UploadProject`
- Ruta `/uploadproject` ahora usa el componente completo

### 4. Integración

Actualizado `/lib/view/Project/Project.dart`:
- Botón elegante para agregar proyectos (solo visible si está autenticado)
- Diseño con gradiente y animación

## 🔥 Estructura de Datos en Firebase

Los proyectos se guardan en Firebase Realtime Database con la siguiente estructura:

```json
{
  "Projects": {
    "uuid-del-proyecto": {
      "name": "Nombre del Proyecto",
      "description": "Descripción detallada...",
      "link": "https://ejemplo.com",
      "images": [
        "https://firebasestorage.googleapis.com/.../imagen1.png",
        "https://firebasestorage.googleapis.com/.../imagen2.png"
      ],
      "imagesMobile": [
        "https://firebasestorage.googleapis.com/.../mobile1.jpg",
        "https://firebasestorage.googleapis.com/.../mobile2.jpg"
      ],
      "timestamp": "2025-03-15T20:14:48.783Z"
    }
  }
}
```

## 📦 Dependencias Agregadas

En `pubspec.yaml`:
```yaml
dependencies:
  file_picker: ^8.0.0+1  # Para seleccionar archivos
  image_picker: ^1.0.7    # Para seleccionar imágenes (mobile)
```

## 🚀 Cómo Usar

### 1. Acceso al Módulo

#### Opción A: Desde la Página de Proyectos
1. Ve a `/project`
2. Si estás autenticado, verás un botón grande "Agregar Nuevo Proyecto"
3. Haz clic en el botón

#### Opción B: Directamente
1. Navega a `/uploadproject`
2. Si no estás autenticado, verás un mensaje para iniciar sesión

### 2. Subir un Proyecto

1. **Inicia sesión** primero (si no lo has hecho)
2. **Completa el formulario**:
   - Nombre del proyecto (máx. 100 caracteres)
   - Descripción (máx. 1000 caracteres)
   - Link del proyecto (debe comenzar con http:// o https://)
3. **Agrega imágenes**:
   - Haz clic en "Agregar Imágenes" en la sección Web
   - Selecciona una o más imágenes
   - Repite para la sección Mobile
4. **Guarda**:
   - Haz clic en "GUARDAR PROYECTO"
   - Verás una barra de progreso
   - Al finalizar, serás redirigido a `/project`

### 3. Ver el Progreso

Durante la subida verás:
- Spinner circular
- Mensaje de estado ("Subiendo imágenes web...", etc.)
- Barra de progreso lineal
- Porcentaje completado

## 🔐 Autenticación

El módulo está **protegido con autenticación**:

- ✅ Solo usuarios autenticados pueden subir proyectos
- ✅ El botón solo aparece si estás autenticado
- ✅ Si intentas acceder sin autenticarte, verás un mensaje

### Requisitos:
1. Firebase Authentication debe estar habilitado (Email/Password)
2. Debes haber iniciado sesión previamente

## 🎨 UI/UX

### Diseño
- **Responsive**: Funciona en móvil, tablet y desktop
- **Colores**: Usa la paleta de AppColors
- **Animaciones**: FadeInDown para el botón de agregar

### Validaciones
- ✅ Todos los campos son requeridos
- ✅ Link debe empezar con http:// o https://
- ✅ Debe haber al menos una imagen (web o mobile)
- ✅ Mensajes de error claros

### Feedback
- ✅ Snackbars para errores y éxitos
- ✅ Barra de progreso durante la subida
- ✅ Vista previa de imágenes seleccionadas
- ✅ Botón deshabilitado durante la subida

## 📝 Ejemplo de Uso

```dart
// Navegar programáticamente
context.go('/uploadproject');

// O usando el helper
AppNavigator.goToUploadProject(context);
```

## 🐛 Solución de Problemas

### Error: "Debes agregar al menos una imagen"
- **Causa**: No has seleccionado ninguna imagen
- **Solución**: Agrega al menos una imagen en Web o Mobile

### Error: "El link debe comenzar con http://"
- **Causa**: El link no tiene el protocolo
- **Solución**: Agrega `https://` al inicio del link

### Error: "Error al subir imagen"
- **Causa**: Problema con Firebase Storage
- **Solución**: Verifica que Firebase Storage esté configurado y que tengas permisos

### No puedo ver el botón "Agregar Proyecto"
- **Causa**: No estás autenticado
- **Solución**: Inicia sesión primero desde `/login`

## 🔧 Configuración de Firebase

### Storage Rules
Asegúrate de tener las reglas de Storage configuradas:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /Project/{allPaths=**} {
      allow read: if true;  // Público para lectura
      allow write: if request.auth != null;  // Solo autenticados pueden escribir
    }
  }
}
```

### Realtime Database Rules
```json
{
  "rules": {
    "Projects": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

## ✨ Características

- ✅ **Subida múltiple**: Sube varias imágenes a la vez
- ✅ **Progreso en tiempo real**: Ve el avance de la subida
- ✅ **Vista previa**: Revisa las imágenes antes de subir
- ✅ **Validación**: Formulario con validación completa
- ✅ **Responsive**: Funciona en todos los dispositivos
- ✅ **Protegido**: Solo usuarios autenticados
- ✅ **Integrado**: Botón visible en la página de proyectos

## 📚 Recursos

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Realtime Database Documentation](https://firebase.google.com/docs/database)
- [file_picker Package](https://pub.dev/packages/file_picker)

## 🎉 ¡Listo!

El módulo está completamente funcional y listo para usar. Los usuarios autenticados ya pueden subir proyectos con imágenes desde la interfaz.
