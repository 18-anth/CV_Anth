import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:cv_anth/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cv_anth/firebase_options.dart';
import 'package:cv_anth/services/env_loader.dart';
import 'package:cv_anth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

// 🌍 Variable global para el controlador de autenticación (se inicializa después de Firebase)
late AuthController authController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📁 Cargar variables de entorno
  try {
    await EnvLoader.loadEnv();
    print('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    print('⚠️ Error al cargar variables de entorno: $e');
  }

  // 🔥 Inicializar Firebase PRIMERO
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('⚠️ Error al inicializar Firebase: $e');
  }

  // 🔐 DESPUÉS inicializar AuthController (ahora Firebase ya existe)
  authController = AuthController();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    setState(() {
      // Reconstruir el widget cuando cambie el estado de autenticación
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authController,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Anthony C',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.light),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
