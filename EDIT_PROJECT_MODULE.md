# ✏️ Módulo de Edición de Proyectos

## 🎯 Descripción

Módulo completo para **editar proyectos existentes** con todos sus campos e imágenes. Permite a usuarios autenticados modificar:

- ✅ Nombre del proyecto
- ✅ Descripción detallada
- ✅ Link del proyecto
- ✅ Imágenes para Web (agregar nuevas o eliminar existentes)
- ✅ Imágenes para Mobile (agregar nuevas o eliminar existentes)

## 📁 Archivos Modificados/Creados

### 1. Nueva Pantalla

#### `/lib/view/Project/EditProject.dart` ⭐ NUEVO

Pantalla completa de edición con:

- Carga automática de datos del proyecto existente
- Pre-visualización de imágenes existentes (desde URLs de Firebase)
- Selector para agregar nuevas imágenes
- Capacidad de eliminar imágenes existentes
- Capacidad de eliminar imágenes recién agregadas
- Diferenciación visual entre imágenes existentes y nuevas (badge "NUEVA")
- Validación completa del formulario
- Barra de progreso durante la actualización
- Protección con autenticación

### 2. Rutas Actualizadas

#### `/lib/routes/app_routes.dart`

Cambios realizados:

- ✅ Import: `import 'package:cv_anth/view/Project/EditProject.dart';`
- ✅ Constante: `static const String editProject = '/project/:id/edit';`
- ✅ Helper: `goToEditProject(BuildContext context, String id)`
- ✅ Ruta: `/project/:id/edit` que recibe el projectId y carga EditProject

### 3. Integración en Detalle

#### `/lib/view/Project/ProjectDetail.dart`

Cambios realizados:

- ✅ Imports: `provider` y `auth_controller`
- ✅ Botón de editar en AppBar (actions)
- ✅ Solo visible si el usuario está autenticado
- ✅ Icono de lápiz con tooltip "Editar Proyecto"
- ✅ Navega a `/project/:id/edit` al hacer clic

### 4. Servicios (Sin cambios necesarios)

Los métodos existentes en `FirebaseService` ya soportan la edición:

- `saveProject()` - Acepta un `id` opcional para actualizar
- `fetchProjectById()` - Obtiene los datos del proyecto
- `FirebaseStorageService.uploadMultipleImages()` - Sube nuevas imágenes

## 🔄 Flujo de Edición

```
1. Usuario autenticado ve proyecto en ProjectDetail.dart
2. Hace clic en botón de editar (icono de lápiz en AppBar)
3. Se navega a /project/{id}/edit
4. EditProject.dart carga los datos del proyecto
5. Muestra formulario pre-llenado con datos existentes
6. Muestra imágenes existentes con posibilidad de eliminarlas
7. Usuario puede:
   - Modificar nombre, descripción, link
   - Eliminar imágenes existentes
   - Agregar nuevas imágenes (web/mobile)
   - Eliminar imágenes recién agregadas (antes de guardar)
8. Al guardar:
   - Se suben las nuevas imágenes a Firebase Storage
   - Se combinan URLs existentes + nuevas
   - Se actualiza el proyecto en Firebase Database (mismo ID)
9. Mensaje de éxito y redirección a /project/{id}
```

## 🖼️ Gestión de Imágenes

### Imágenes Existentes

- Se cargan desde Firebase Database (campo `images` y `imagesMobile`)
- Se muestran usando `NetworkImage` (URLs completas)
- Tienen botón X rojo para eliminarlas
- Al eliminar, simplemente se quitan de la lista antes de guardar

### Imágenes Nuevas

- Se seleccionan con `FilePicker`
- Se muestran usando `Image.memory()` (web) o `Image.file()` (móvil)
- Tienen borde verde para distinguirlas
- Tienen badge "NUEVA" en la esquina
- Tienen botón X rojo para cancelar (antes de subir)
- Se suben a Firebase Storage al guardar

### Al Actualizar

1. Las **nuevas imágenes** se suben a Storage → obtienen URLs
2. Las **URLs existentes no eliminadas** se conservan
3. Se combinan ambas listas: `[...existentes, ...nuevas]`
4. Se guarda el proyecto con el array combinado

## 🚀 Cómo Usar

### Desde la UI

#### Opción 1: Desde el Detalle del Proyecto

1. **Inicia sesión** (si no lo has hecho)
2. Ve a cualquier proyecto: `/project/{id}`
3. Verás un **icono de lápiz** (✏️) en el AppBar (arriba a la derecha)
4. Haz clic en el icono

#### Opción 2: Programáticamente

```dart
// Usando el helper
AppNavigator.goToEditProject(context, projectId);

// O directamente
context.go('/project/$projectId/edit');
```

### Editar el Proyecto

1. **Modifica los campos** que desees:
   - Nombre del proyecto
   - Descripción
   - Link (debe comenzar con http:// o https://)

2. **Gestionar Imágenes Web**:
   - Ver imágenes actuales
   - Eliminar imágenes existentes (clic en X roja)
   - Agregar nuevas imágenes (botón "Agregar Imágenes")
   - Eliminar imágenes recién agregadas (antes de guardar)

3. **Gestionar Imágenes Mobile**:
   - Misma funcionalidad que imágenes web

4. **Guardar**:
   - Haz clic en "ACTUALIZAR PROYECTO"
   - Verás progreso de subida si agregaste imágenes nuevas
   - Al finalizar, se redirige al detalle del proyecto

### Validaciones

- ✅ Todos los campos son requeridos (nombre, descripción, link)
- ✅ Link debe empezar con http:// o https://
- ✅ Debe haber al menos 1 imagen (existente o nueva, web o mobile)
- ✅ Máximo 100 caracteres para nombre
- ✅ Máximo 1000 caracteres para descripción

## 🔐 Autenticación

El módulo está **protegido con autenticación**:

- ✅ Solo usuarios autenticados pueden editar
- ✅ El botón de editar solo aparece si estás autenticado
- ✅ Si intentas acceder sin autenticarte, verás mensaje de login

### Requisitos:

1. Debes haber iniciado sesión con Email/Password
2. Firebase Authentication debe estar habilitado

## 🎨 Interfaz de Usuario

### Diseño Visual

#### Imágenes Existentes

- Fondo gris claro
- Sin borde especial
- Botón X rojo para eliminar

#### Imágenes Nuevas (Sin subir aún)

- **Borde verde** (2px)
- **Badge "NUEVA"** en verde en la esquina inferior izquierda
- Botón X rojo para cancelar

### Secciones del Formulario

1. **Encabezado**:
   - Título: "Edita la información de tu proyecto"
   - Subtítulo: "Modifica los campos que desees actualizar"

2. **Campos de Texto**:
   - Nombre del Proyecto (icono de título)
   - Descripción (icono de descripción, multilínea)
   - Link del Proyecto (icono de link)

3. **Sección Imágenes Web**:
   - Icono de computadora (azul)
   - Contador de imágenes
   - Botón "Agregar Imágenes"
   - Grid de imágenes existentes
   - Grid de imágenes nuevas

4. **Sección Imágenes Mobile**:
   - Icono de teléfono (verde)
   - Misma estructura que web

5. **Botón de Guardar**:
   - Grande, prominente
   - Texto: "ACTUALIZAR PROYECTO"
   - Color primario de la app

### Durante la Actualización

- Spinner circular
- Mensaje de estado:
  - "Preparando..."
  - "Subiendo nuevas imágenes web..."
  - "Subiendo nuevas imágenes mobile..."
  - "Actualizando proyecto..."
  - "¡Proyecto actualizado exitosamente!"
- Barra de progreso lineal
- Porcentaje completado

## 📝 Ejemplo de Código

### Navegar a Edición

```dart
// Desde ProjectDetail o cualquier lugar
import 'package:cv_anth/routes/app_routes.dart';

// Opción 1: Usando helper
AppNavigator.goToEditProject(context, projectId);

// Opción 2: Directamente con go_router
context.go('/project/$projectId/edit');
```

### Verificar Autenticación

```dart
import 'package:provider/provider.dart';
import 'package:cv_anth/controllers/auth_controller.dart';

// En cualquier widget
final auth = context.read<AuthController>();
if (auth.isAuthenticated) {
  // Mostrar botón de editar
}
```

## 🔧 Detalles Técnicos

### Gestión de Estado

- **Local State**: `_EditProjectState` maneja:
  - Formulario (`_formKey`)
  - Controladores de texto
  - Listas de imágenes (existentes y nuevas)
  - Estado de carga y progreso

### Almacenamiento

#### Firebase Realtime Database

```json
{
  "Projects": {
    "existing-uuid": {
      "name": "Nombre Actualizado",
      "description": "Descripción actualizada...",
      "link": "https://example.com",
      "images": [
        "https://storage.../existing1.jpg", // Existente conservada
        "https://storage.../new1.jpg" // Nueva agregada
      ],
      "imagesMobile": [
        "https://storage.../existing_mobile1.jpg",
        "https://storage.../new_mobile1.jpg"
      ],
      "timestamp": "2025-05-01T15:30:00.000Z" // Se actualiza
    }
  }
}
```

#### Firebase Storage

- Nuevas imágenes web → `/Project/Web/{timestamp}_{filename}`
- Nuevas imágenes mobile → `/Project/Mobile/{timestamp}_{filename}`
- Las imágenes eliminadas permanecen en Storage (no se borran automáticamente)

### Métodos Principales

#### `_loadProjectData()`

- Carga el proyecto desde Firebase usando el `projectId`
- Llena los controladores de texto
- Carga las listas de imágenes existentes
- Maneja errores (proyecto no encontrado)

#### `_updateProject()`

1. Valida formulario
2. Valida que haya al menos 1 imagen
3. Sube nuevas imágenes web con progreso
4. Sube nuevas imágenes mobile con progreso
5. Combina URLs: `[...existentes, ...nuevas]`
6. Llama a `FirebaseService.saveProject()` con el ID existente
7. Muestra mensaje de éxito
8. Navega de vuelta al detalle

#### Métodos de Imágenes

- `_pickNewWebImages()` - FilePicker para web
- `_pickNewMobileImages()` - FilePicker para mobile
- `_removeExistingWebImage(index)` - Elimina de lista existente
- `_removeExistingMobileImage(index)` - Elimina de lista existente
- `_removeNewWebImage(index)` - Cancela imagen nueva
- `_removeNewMobileImage(index)` - Cancela imagen nueva

## 🐛 Solución de Problemas

### Error: "Proyecto no encontrado"

- **Causa**: El ID del proyecto no existe en Firebase
- **Solución**: Verifica que el ID es correcto

### Error: "Debes tener al menos una imagen"

- **Causa**: Eliminaste todas las imágenes (existentes y nuevas)
- **Solución**: Deja al menos una imagen o agrega una nueva

### Error: "El link debe comenzar con http://"

- **Causa**: El link no tiene protocolo
- **Solución**: Agrega `https://` al inicio

### No puedo ver el botón de editar

- **Causa**: No estás autenticado
- **Solución**: Inicia sesión desde `/login`

### Las imágenes no se cargan

- **Causa**: URLs rotas o permisos de Storage
- **Solución**: Verifica las reglas de Firebase Storage y que las URLs sean válidas

## ✨ Características Destacadas

- ✅ **Pre-carga de datos**: Carga automática del proyecto existente
- ✅ **Gestión inteligente de imágenes**: Distingue entre existentes y nuevas
- ✅ **Feedback visual**: Bordes y badges para identificar imágenes nuevas
- ✅ **Progreso detallado**: Muestra el avance de la subida
- ✅ **Validación completa**: Formulario y validación de imágenes
- ✅ **Responsive**: Funciona en móvil, tablet y desktop
- ✅ **Protegido**: Solo usuarios autenticados
- ✅ **Integrado**: Botón visible en el detalle del proyecto

## 🔄 Diferencias con UploadProject

| Característica      | UploadProject             | EditProject           |
| ------------------- | ------------------------- | --------------------- |
| **Propósito**       | Crear nuevo               | Actualizar existente  |
| **ID**              | Se genera automáticamente | Se usa el existente   |
| **Datos iniciales** | Vacíos                    | Pre-cargados          |
| **Imágenes**        | Solo nuevas               | Existentes + nuevas   |
| **Botón guardar**   | "GUARDAR PROYECTO"        | "ACTUALIZAR PROYECTO" |
| **Redirección**     | `/project`                | `/project/{id}`       |
| **Carga inicial**   | No                        | Sí (fetchProjectById) |

## 📚 Recursos

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Realtime Database Documentation](https://firebase.google.com/docs/database)
- [file_picker Package](https://pub.dev/packages/file_picker)
- [go_router Package](https://pub.dev/packages/go_router)

## 🎉 ¡Listo para Usar!

El módulo de edición está completamente funcional y listo para usar. Los usuarios autenticados pueden ahora:

1. ✅ Ver el botón de editar en cada proyecto
2. ✅ Modificar todos los campos del proyecto
3. ✅ Agregar nuevas imágenes
4. ✅ Eliminar imágenes existentes
5. ✅ Ver progreso en tiempo real
6. ✅ Confirmar cambios y volver al detalle

**¡Disfruta editando tus proyectos!** 🚀
