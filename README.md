# 🌐 CV { Anth } - Portafolio Web Personal

Un portafolio web interactivo y moderno desarrollado en **Flutter** que exhibe proyectos, certificaciones y experiencia profesional. Incluye un panel de administración completo para gestionar contenidos, autenticación con Google, integración con Firebase, y acceso a Google Drive para cargas de archivos.

---

## 📋 Tabla de Contenidos

- [Descripcion General](#descripcion-general)
- [Características Principales](#características-principales)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Instalación y Configuración](#instalación-y-configuración)
- [Rutas y Navegación](#rutas-y-navegación)
- [Modelos de Datos](#modelos-de-datos)
- [Servicios](#servicios)
- [Controladores](#controladores)
- [Componentes Principales](#componentes-principales)
- [Firebase Setup](#firebase-setup)
- [Guías de Configuración](#guías-de-configuración)
- [Desarrollo](#desarrollo)
- [Contribución](#contribución)

---

## 🎯 Descripción General

**CV { Anth }** es una aplicación Flutter multiplataforma que funciona como portafolio profesional interactivo. Permite:

- ✅ Visualizar proyectos y certificaciones en una galería atractiva
- ✅ Autenticación segura mediante Google Sign-In
- ✅ Panel de administración para cargar/editar contenidos
- ✅ Almacenamiento en Firebase (Realtime Database, Cloud Storage, Cloud Firestore)
- ✅ Integración con Google Drive para gestión de archivos
- ✅ Visor de PDF integrado
- ✅ Visualización de modelos 3D
- ✅ Responsive design para web, móvil y desktop
- ✅ Soporte multiplataforma: iOS, Android, Web, macOS, Windows, Linux

---

## ✨ Características Principales

### 🏠 Home (Pantalla Principal)

- Interfaz atractiva con animaciones
- Stack de tecnologías destacadas
- Visualización de particulas animadas de fondo
- Preview del dispositivo iPhone 15 Pro Max
- Botones de navegación rápida

### 📱 Proyectos

- **Galería de Proyectos:** Lista completa de todos los proyectos
- **Detalle del Proyecto:** Vista completa con:
  - Descripción detallada
  - Tecnologías utilizadas
  - Galería de imágenes
  - Enlaces a GitHub y demo en vivo
  - Información de timestamps
- **Subir Proyecto:** Panel de administración para crear nuevos proyectos
- **Editar Proyecto:** Modificación de proyectos existentes

### 🏆 Certificaciones

- **Galería de Certificaciones:** Listado de todas las certificaciones obtenidas
- **Detalle de Certificación:** Vista con:
  - Información completa de la certificación
  - Visor de PDF integrado
  - Enlace asociado (si está disponible)
- **Subir Certificación:** Formulario para añadir nuevas certificaciones con PDF
- **Editar Certificación:** Modificación de certificaciones

### 👤 Sobre Mí

- Presentación personal
- Experiencia profesional
- Habilidades técnicas
- Objetivos y aspiraciones

### ✉️ Contacto

- Formulario de contacto directo
- Integración con servicios de mensajería

### 🔐 Autenticación

- Login con Google
- Protección de rutas administrativas
- Gestión segura de sesiones
- Logout y cierre de sesión

### ⚖️ Legal

- Página de Términos de Servicio
- Página de Política de Privacidad

---

## 🛠️ Tecnologías Utilizadas

### Core

- **Framework:** Flutter 3.8.1+
- **Lenguaje:** Dart
- **State Management:** Provider 6.1.5
- **Routing:** GoRouter 14.0.0

### Backend & Database

- **Firebase Core:** 4.6.0
- **Firebase Authentication:** 6.4.0
- **Firebase Realtime Database:** 12.2.0
- **Cloud Firestore:** 6.3.0
- **Firebase Storage:** 13.2.0
- **Google Sign-In:** 6.2.1 (con soporte web)

### Google APIs

- **Google Drive API:** Integración completa
- **googleapis:** 13.2.0
- **Google Sign-In Web:** 0.12.4+2
- **Extension Google Sign-In:** 2.0.12

### UI & Visualización

- **Material Design 3:** Cupertino Icons 1.0.8
- **Material Design Icons Flutter:** 7.0.7296
- **Animate Do:** 3.2.2 (Animaciones)
- **Syncfusion PDF Viewer:** 27.2.4
- **Flutter PDF View:** 1.0.4
- **WebView Flutter:** 4.8.0
- **Model Viewer Plus:** 1.0.0 (Visualización 3D)
- **Flutter 3D Controller:** 2.3.0

### Utilidades

- **File Picker:** 8.0.0+1
- **Image Picker:** 1.0.7
- **Path Provider:** 2.1.1
- **Share Plus:** 12.0.2
- **URL Launcher:** 6.2.0
- **HTTP:** 1.1.0
- **Universal HTML:** 2.2.4

---

## 📁 Estructura del Proyecto

```bash
cv_anth/
├── lib/
│   ├── main.dart                          # Punto de entrada de la aplicación
│   ├── firebase_options.dart              # Configuración de Firebase
│   │
│   ├── routes/
│   │   └── app_routes.dart                # Definición de todas las rutas
│   │
│   ├── layouts/
│   │   └── main_layout.dart               # Layout principal de la app
│   │
│   ├── view/                              # Pantallas/Vistas
│   │   ├── Home/
│   │   │   ├── Homescreen.dart
│   │   │   └── home_tech.dart
│   │   ├── Auth/
│   │   │   └── LoginScreen.dart
│   │   ├── Project/
│   │   │   ├── Project.dart               # Galería de proyectos
│   │   │   ├── ProjectDetail.dart         # Detalle del proyecto
│   │   │   ├── UploadProject.dart         # Subir nuevo proyecto
│   │   │   └── EditProject.dart           # Editar proyecto
│   │   ├── Certifications/
│   │   │   ├── Certification.dart         # Galería de certificaciones
│   │   │   ├── CertificationDetail.dart   # Detalle de certificación
│   │   │   ├── UploadCertification.dart   # Subir certificación
│   │   │   └── EditCertification.dart     # Editar certificación
│   │   ├── About/
│   │   │   └── AboutMe.dart               # Página de perfil
│   │   ├── Contact/
│   │   │   └── Contact.dart               # Formulario de contacto
│   │   └── Legal/
│   │       ├── TermsScreen.dart           # Términos de servicio
│   │       └── PrivacyScreen.dart         # Política de privacidad
│   │
│   ├── widgets/                           # Componentes reutilizables
│   │   ├── auth_wrapper.dart              # Wrapper de autenticación
│   │   ├── particle_background.dart       # Fondo con partículas animadas
│   │   ├── certification_widgets.dart     # Widgets para certificaciones
│   │   ├── editable_widgets.dart          # Widgets editables
│   │   ├── home_tech_stack.dart           # Stack de tecnologías
│   │   ├── robot_model.dart               # Modelo 3D del robot
│   │   ├── Certification/                 # Widgets específicos de certificaciones
│   │   ├── EditCertification/             # Componentes de edición
│   │   │   ├── edit_auth_dialog.dart
│   │   │   ├── edit_logo_selector.dart
│   │   │   ├── edit_pdf_selector.dart
│   │   │   ├── edit_uploading_widget.dart
│   │   │   └── edit_user_info_banner.dart
│   │   ├── ProjectDetail/                 # Componentes de detalle de proyecto
│   │   │   ├── project_detail_image_gallery.dart
│   │   │   ├── project_detail_info_slider.dart
│   │   │   ├── project_detail_technologies.dart
│   │   │   └── project_detail_view_tab.dart
│   │   ├── UploadCertification/           # Componentes de subida de certificación
│   │   │   ├── upload_auth_dialog.dart
│   │   │   ├── upload_logo_selector.dart
│   │   │   ├── upload_pdf_selector.dart
│   │   │   ├── upload_uploading_widget.dart
│   │   │   └── upload_user_info_banner.dart
│   │   └── UploadProject/                 # Componentes de subida de proyecto
│   │
│   ├── controllers/                       # Controladores de lógica
│   │   ├── auth_controller.dart           # Control de autenticación
│   │   ├── upload_certification_controller.dart
│   │   ├── upload_project_controller.dart
│   │   ├── edit_certification_controller.dart
│   │   ├── project_detail_controller.dart
│   │   └── ...
│   │
│   ├── services/                          # Servicios de negocio
│   │   ├── firebase_service.dart          # Servicio Firebase Realtime DB
│   │   ├── firebase_storage_service.dart  # Servicio de almacenamiento
│   │   ├── google_auth_web.dart           # Autenticación Google Web
│   │   ├── google_drive_service.dart      # Servicio Google Drive
│   │   ├── google_drive_upload_service.dart
│   │   ├── env_loader.dart                # Cargador de variables de entorno
│   │   ├── app_config.dart                # Configuración de la app
│   │   └── ...
│   │
│   ├── models/                            # Modelos de datos
│   │   ├── user_model.dart                # Modelo de usuario
│   │   ├── BookModel.dart
│   │   ├── ContactModel.dart
│   │   ├── RobotModel.dart
│   │   ├── TreeModel.dart
│   │   ├── AvatarAbstractoModel.dart
│   │   └── ...
│   │
│   ├── Components/                        # Componentes específicos
│   │   ├── device_frame.dart              # Marco del dispositivo
│   │   ├── mobile_preview.dart            # Preview móvil
│   │   ├── iphone_webview.dart            # WebView de iPhone
│   │   ├── simple_preview.dart
│   │   ├── particle_background_flutter.dart
│   │   └── robot_model.dart
│   │
│   └── utils/                             # Utilidades
│       ├── asset_paths.dart               # Rutas de assets
│       ├── Colors.dart                    # Paleta de colores
│       ├── google_drive_utils.dart        # Utilidades de Google Drive
│       ├── web_pdf_viewer.dart            # Visor de PDF multiplataforma
│       ├── web_pdf_viewer_web.dart        # Implementación Web
│       └── web_pdf_viewer_stub.dart       # Stub para plataformas no soportadas
│
├── assets/
│   ├── img/                               # Imágenes y logos
│   ├── svg/                               # Archivos SVG
│   └── env.txt                            # Variables de entorno (PLACEHOLDER)
│
├── android/                               # Configuración Android
├── ios/                                   # Configuración iOS
├── web/                                   # Configuración Web
├── macos/                                 # Configuración macOS
├── windows/                               # Configuración Windows
├── linux/                                 # Configuración Linux
│
├── scripts/                               # Scripts de utilidad
│   ├── setup-sync.sh                      # Setup de sincronización
│   ├── sync-certifications.js             # Sincronización de certificaciones
│   └── README.md                          # Documentación de scripts
│
├── pubspec.yaml                           # Archivo de dependencias Flutter
├── firebase.json                          # Configuración de Firebase
├── analysis_options.yaml                  # Opciones de análisis estático
├── devtools_options.yaml                  # Opciones de DevTools
├── git.txt                                # Información de git
└── README.md                              # Este archivo

```

---

## 📱 Instalación y Configuración

### Requisitos Previos

- **Flutter SDK:** 3.8.1 o superior
- **Dart:** 3.8.1 o superior
- **Node.js:** (para scripts de sincronización)
- **Firebase Project:** Configurado en Firebase Console
- **Google Cloud Project:** Con APIs habilitadas

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/18-anth/CV_Anth.git
cd cv_anth
```

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

### Paso 3: Configurar Variables de Entorno

Crear archivo `.env` en la raíz del proyecto:

```env
GOOGLE_DRIVE_FOLDER_ID=tu_folder_id_aqui
FIREBASE_DATABASE_URL=tu_database_url
FIREBASE_STORAGE_BUCKET=tu_bucket
GOOGLE_CLIENT_ID=tu_client_id
GOOGLE_CLIENT_SECRET=tu_client_secret
```

### Paso 4: Configurar Firebase

Seguir las instrucciones en [FIREBASE_AUTH_SETUP.md](./FIREBASE_AUTH_SETUP.md) y [GOOGLE_CLOUD_CONSOLE_SETUP.md](./GOOGLE_CLOUD_CONSOLE_SETUP.md)

### Paso 5: Ejecutar la Aplicación

**Web:**

```bash
flutter run -d chrome
```

**Android:**

```bash
flutter run -d android
```

**iOS:**

```bash
flutter run -d ios
```

**Desktop (macOS):**

```bash
flutter run -d macos
```

---

## 🗺️ Rutas y Navegación

La aplicación utiliza **GoRouter** para navegación. Todas las rutas están definidas en [app_routes.dart](./lib/routes/app_routes.dart).

### Rutas Públicas

| Ruta                 | Descripción                | Componente            |
| -------------------- | -------------------------- | --------------------- |
| `/`                  | Pantalla de inicio         | `Homescreen`          |
| `/login`             | Pantalla de login (modal)  | `LoginScreen`         |
| `/project`           | Galería de proyectos       | `Project`             |
| `/project/:id`       | Detalle del proyecto       | `ProjectDetail`       |
| `/aboutme`           | Página de perfil           | `AboutMe`             |
| `/certification`     | Galería de certificaciones | `Certification`       |
| `/certification/:id` | Detalle de certificación   | `CertificationDetail` |
| `/contact`           | Formulario de contacto     | `Contact`             |
| `/terms`             | Términos de servicio       | `TermsScreen`         |
| `/privacy`           | Política de privacidad     | `PrivacyScreen`       |

### Rutas Protegidas (Requieren Autenticación)

| Ruta                      | Descripción               | Componente            |
| ------------------------- | ------------------------- | --------------------- |
| `/uploadproject`          | Subir nuevo proyecto      | `UploadProject`       |
| `/project/:id/edit`       | Editar proyecto existente | `EditProject`         |
| `/uploadcertification`    | Subir nueva certificación | `UploadCertification` |
| `/certification/:id/edit` | Editar certificación      | `EditCertification`   |

### Clase de Navegación (AppNavigator)

Utiliza métodos estáticos para navegar de forma segura:

```dart
// Navegar al home
AppNavigator.goHome(context);

// Navegar a detalle de proyecto
AppNavigator.goToProjectDetail(context, projectId);

// Navegar a subida de proyecto
AppNavigator.goToUploadProject(context);
```

---

## 📊 Modelos de Datos

### UserModel

Representa los datos del usuario autenticado.

```dart
class UserModel {
  final String email;
  final String? displayName;
  final DateTime? createdAt;
  
  // Métodos: toJson(), fromJson(), copyWith()
}
```

### Proyectos (Firebase Realtime Database)

Estructura en la Realtime Database bajo nodo `Projects`:

```json
{
  "Projects": {
    "project_key_1": {
      "name": "Nombre del Proyecto",
      "description": "Descripción completa",
      "timestamp": 1698765432,
      "githubUrl": "https://github.com/...",
      "demoUrl": "https://demo.com",
      "technologies": ["Flutter", "Firebase", "Google Drive"],
      "driveFileId": "file_id_para_imagen_principal"
    }
  }
}
```

### Certificaciones (Firebase Realtime Database)

Estructura bajo nodo `Certifications`:

```json
{
  "Certifications": {
    "cert_key_1": {
      "name": "Nombre de la Certificación",
      "description": "Descripción de la certificación",
      "driveFileId": "google_drive_file_id_del_pdf",
      "imageUrl": "url_de_imagen_opcional",
      "link": "url_opcional_relacionada"
    }
  }
}
```

### Otros Modelos

- **BookModel:** Modelo para libros
- **ContactModel:** Datos de contacto
- **RobotModel:** Configuración del modelo 3D del robot
- **TreeModel:** Modelo jerárquico
- **AvatarAbstractoModel:** Modelo abstracto para avatares

---

## 🔧 Servicios

### FirebaseService

Servicio encargado de comunicarse con **Firebase Realtime Database**.

**Métodos principales:**

- `fetchProjects()` - Obtiene todos los proyectos
- `fetchProjectById(id)` - Obtiene un proyecto específico
- `fetchCertifications()` - Obtiene todas las certificaciones
- `fetchCertificationById(id)` - Obtiene una certificación

```dart
List<Map<String, dynamic>> projects = await FirebaseService.fetchProjects();
Map<String, dynamic>? project = await FirebaseService.fetchProjectById('project_id');
```

### FirebaseStorageService

Gestiona subidas y descargas de **Firebase Storage**.

**Métodos:**

- Subida de imágenes
- Subida de PDFs
- Gestión de archivos

### GoogleDriveService

Integración completa con **Google Drive API**.

**Funcionalidades:**

- Listar archivos en Google Drive
- Cargar archivos a Google Drive
- Obtener información de archivos
- Sincronización de contenidos

### GoogleDriveUploadService

Servicio especializado para cargas a Google Drive con:

- Soporte de progreso
- Manejo de errores
- Retorno de IDs de archivo

### EnvLoader

Cargador de variables de entorno desde `.env` y `assets/env.txt`.

```dart
await EnvLoader.loadEnv();
String? folderId = EnvLoader.getValue('GOOGLE_DRIVE_FOLDER_ID');
```

### AppConfig

Configuración centralizada de la aplicación.

### GoogleAuthWeb

Autenticación específica para la plataforma web con Google Sign-In.

---

## 🎮 Controladores

### AuthController (Más Importante)

Extiende `ChangeNotifier` y gestiona:

- Estado de autenticación del usuario
- Login con Google
- Logout
- Verificación de usuario autenticado
- Persistencia de sesión

```dart
// Verificar si está autenticado
authController.isAuthenticatedUser

// Obtener usuario actual
User? user = authController.currentUser;

// Login
await authController.login();

// Logout
await authController.logout();
```

### Otros Controladores

- **UploadProjectController:** Gestiona la carga de proyectos
- **UploadCertificationController:** Gestiona la carga de certificaciones
- **EditProjectController:** Lógica de edición de proyectos
- **EditCertificationController:** Lógica de edición de certificaciones
- **ProjectDetailController:** Lógica de vista de detalle
- **UploadCertificationController:** Carga de certificaciones

---

## 🎨 Componentes Principales

### Layouts

**MainLayout:** Layout principal que envuelve toda la aplicación con navegación, header, footer y contenido principal.

### Components Especiales

- **DeviceFrame:** Marco de dispositivo para mostrar la app dentro de un teléfono
- **MobilePreview:** Vista previa móvil responsive
- **iPhoneWebView:** WebView dentro de un iPhone
- **ParticleBackgroundFlutter:** Fondo animado con partículas
- **RobotModel:** Modelo 3D del robot (motor Physics)
- **SimplePreview:** Preview simplificado

### Widgets Reutilizables

- **AuthWrapper:** Wrapper que maneja autenticación
- **ParticleBackground:** Sistema de partículas animadas
- **CertificationWidgets:** Componentes para certificaciones
- **EditableWidgets:** Widgets editables in-place
- **HomeTechStack:** Galería de stack tecnológico

### Widgets de Subida (Upload)

Componentes modulares para formularios de subida:

- AuthDialog
- LogoSelector
- PDFSelector
- UploadingWidget
- UserInfoBanner

### Widgets de Edición (Edit)

Componentes para formularios de edición:

- EditAuthDialog
- EditLogoSelector
- EditPDFSelector
- EditUploadingWidget
- EditUserInfoBanner

### Widgets de Detalle de Proyecto

- ImageGallery
- InfoSlider
- Technologies
- ViewTab

---

## 🔥 Firebase Setup

### Configuración Inicial

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar los siguientes servicios:
   - ✅ Authentication (Google Sign-In)
   - ✅ Realtime Database
   - ✅ Cloud Storage
   - ✅ Cloud Firestore

3. Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)

4. Configurar las reglas de seguridad en Realtime Database:

```json
{
  "rules": {
    "Projects": {
      ".read": true,
      ".write": "auth != null"
    },
    "Certifications": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

### Estructura de Datos Esperada

**Realtime Database:**

```bash
root
├── Projects
│   └── {projectKey}
│       ├── name
│       ├── description
│       ├── technologies
│       ├── timestamp
│       ├── githubUrl
│       ├── demoUrl
│       └── driveFileId
├── Certifications
│   └── {certKey}
│       ├── name
│       ├── description
│       ├── driveFileId
│       ├── imageUrl
│       └── link
```

Ver [FIREBASE_AUTH_SETUP.md](./FIREBASE_AUTH_SETUP.md) para pasos detallados.

---

## 📖 Guías de Configuración

Se incluyen múltiples guías para facilitar la configuración:

### [FIREBASE_AUTH_SETUP.md](./FIREBASE_AUTH_SETUP.md)

Pasos detallados para configurar autenticación Firebase y Google Sign-In.

### [GOOGLE_CLOUD_CONSOLE_SETUP.md](./GOOGLE_CLOUD_CONSOLE_SETUP.md)

Configuración de Google Cloud Console con APIs necesarias.

### [GOOGLE_DRIVE_SETUP.md](./GOOGLE_DRIVE_SETUP.md)

Integración y configuración de Google Drive API.

### [GOOGLE_DRIVE_WEB_SOLUTION.md](./GOOGLE_DRIVE_WEB_SOLUTION.md)

Soluciones específicas para Google Drive en la plataforma web.

### [AUTENTICACION.md](./AUTENTICACION.md)

Documentación de autenticación en español.

### [SOLUCION_GOOGLE_AUTH.md](./SOLUCION_GOOGLE_AUTH.md)

Soluciones comunes para autenticación con Google.

### [SECURITY.md](./SECURITY.md)

Pautas de seguridad del proyecto.

---

## 💻 Desarrollo

### Estructura de Código

- **Separación de responsabilidades:** Models, Services, Controllers, Views
- **State Management:** Provider para reactividad
- **Patrones:** MVC, Singleton, Repository

### Compilación para Diferentes Plataformas

**Web:**

```bash
flutter build web --release
```

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

**Desktop (macOS):**

```bash
flutter build macos --release
```

### Testing

```bash
flutter test
```

### Análisis Estático

```bash
flutter analyze
```

---

## 📋 Scripts Disponibles

En la carpeta `scripts/` se incluyen scripts útiles:

- **setup-sync.sh:** Configuración inicial de sincronización
- **sync-certifications.js:** Sincronización automática de certificaciones

Ver [scripts/README.md](./scripts/README.md) para más detalles.

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la licencia especificada en [LICENSE](./LICENSE).

---

## 📬 Contacto

¿Preguntas o sugerencias? Puedes contactarme a través de:

- **Portafolio:** [CV { Anth }](https://cv-anth.web.app)
- **Email:** [Usar formulario de contacto en la app](https://cv-anth.web.app/contact)
- **GitHub:** [@18-anth](https://github.com/18-anth)

---

## 🎓 Objetivos del Proyecto

Este proyecto demuestra:

✅ Experiencia en **Flutter** multiplataforma  
✅ Integración con **Firebase** (Auth, RTDB, Storage, Firestore)  
✅ Autenticación con **Google Sign-In**  
✅ Integración con **Google Drive API**  
✅ **State Management** con Provider  
✅ **Routing** avanzado con GoRouter  
✅ **UI/UX** responsive y atractiva  
✅ **Arquitectura limpia** y escalable  
✅ Documentación profesional  

---

## 🚀 Roadmap Futuro

- [ ] Integración con más proveedores de autenticación
- [ ] Sistema de comentarios en proyectos
- [ ] Blog integrado
- [ ] Analytics avanzado
- [ ] Optimización de rendimiento
- [ ] Más modelos 3D interactivos
- [ ] Sistema de notificaciones
- [ ] Integración con redes sociales

---

**Última actualización:** 1 de junio de 2026  
**Versión:** 1.0.0
