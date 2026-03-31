# Transformación de React a Flutter

## Componentes Convertidos

### 1. Robot.jsx → robot_model.dart

**Cambios principales:**
- React Hooks (`useState`, `useEffect`) → Flutter State Management
- Three.js & @react-three/fiber → `model_viewer_plus` package
- Firebase Storage API mantenida igual
- Parámetros de cámara y controles de órbita → Propiedades de `ModelViewer`

**Uso:**
```dart
import 'package:cv_anth/Components/robot_model.dart';

// En tu widget
RobotModel()
```

**Características:**
- ✅ Carga el modelo GLB desde Firebase Storage
- ✅ Auto-rotación del modelo
- ✅ Controles de cámara interactivos
- ✅ Manejo de errores y loading

---

### 2. particlesOptions.jsx → particle_background_flutter.dart

**Cambios principales:**
- React Hooks + Particles library → Flutter CustomPaint + AnimationController
- Canvas shapes → Círculos dibujados con `Canvas`
- Interactividad con mouse → Flutter event handling
- Sistema de partículas con física simulada

**Uso:**
```dart
import 'package:cv_anth/Components/particle_background_flutter.dart';

// En tu widget
ParticleBackground(
  particleCount: 60, // Por defecto 60
)

// O con parámetro personalizado
ParticleBackground(particleCount: 100)
```

**Características:**
- ✅ 60 partículas animadas por defecto
- ✅ Movimiento con velocidad variable
- ✅ Rebote en bordes del contenedor
- ✅ Líneas de conexión entre partículas cercanas
- ✅ Animación continua a 60 FPS

---

## Dependencias Requeridas

Asegúrate de que tu `pubspec.yaml` tenga:

```yaml
dependencies:
  flutter:
    sdk: flutter
  model_viewer_plus: ^1.0.0
  firebase_storage: ^13.2.0
```

Si aún no están instaladas, ejecuta:
```bash
flutter pub get
```

---

## Diferencias Importantes

### React → Flutter

| React | Flutter |
|-------|---------|
| `useState` | `StatefulWidget` + `State` |
| `useEffect` | `initState()` + `dispose()` |
| `@react-three/fiber` | `model_viewer_plus` |
| `react-tsparticles` | `CustomPaint` + `AnimationController` |
| `Promise.then().catch()` | `Future` + `async/await` |
| `JSX` | Dart Widgets |

---

## Notas de Implementación

1. **robot_model.dart:**
   - Usa `FutureBuilder` para manejar la carga asincrónica
   - Compatible con Android, iOS, Web, Linux, macOS

2. **particle_background_flutter.dart:**
   - Usa `CustomPainter` para máximo rendimiento
   - Las partículas se inicializan una sola vez al montar el widget
   - El evento `onPointerMove` es opcional (comentado en versión simplificada)
   - Puedes ajustar `particleCount`, velocidad y tamaño en la clase `Particle`

---

## Próximos Pasos

Integra estos componentes en tus vistas actuales:

```dart
// Ejemplo en ProjectDetail.dart u otro widget
Stack(
  children: [
    // Fondo de partículas
    ParticleBackground(),
    // Contenido principal
    Center(
      child: Column(
        children: [
          Text('Mi CV'),
          SizedBox(
            height: 500,
            child: RobotModel(),
          ),
        ],
      ),
    ),
  ],
)
```

---

## Cambios de Archivo

- ✅ Creado: `lib/Components/robot_model.dart`
- ✅ Creado: `lib/Components/particle_background_flutter.dart`
- ℹ️ Archivos React originales pueden ser eliminados cuando estés seguro

