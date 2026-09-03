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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.light,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + (_controller.value * 0.08);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Anthony Córdova',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cargando portfolio...',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.4,
                    color: AppColors.darkgrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplash();
    authController.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _showSplash = false;
    });
  }

  void _onAuthStateChanged() {
    setState(() {
      // Reconstruir el widget cuando cambie el estado de autenticación
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

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
