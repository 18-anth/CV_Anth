import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cv_anth/main.dart' show authController;
import 'package:cv_anth/view/Auth/LoginScreen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;

  const MainLayout({
    Key? key,
    required this.child,
    this.currentRoute,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const List<String> _routePaths = [
    '/',
    '/project',
    '/certification',
    '/contact',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routePaths[index]);
  }

  void _navigateToRoute(String path) {
    setState(() {
      _selectedIndex = _routePaths.indexOf(path);
    });
    context.go(path);
  }

  void _handleLogout() {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Hacer logout
              authController.logout();
              // Actualizar UI
              setState(() {});
            },
            child: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    showLoginDialog(context);
    // Escuchar cambios de autenticación
    authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar índice según la ruta actual
    if (widget.currentRoute != null) {
      int newIndex = _routePaths.indexOf(widget.currentRoute!);
      if (newIndex != -1 && newIndex != _selectedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedIndex = newIndex;
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Anthony'),
        backgroundColor: Color(0xFF0d0d0d),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          // Botón de Login/Logout condicionado por autenticación
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: GestureDetector(
                onTap: authController.isAuthenticated
                    ? _handleLogout
                    : _handleLogin,
                child: Row(
                  children: [
                    Icon(
                      authController.isAuthenticated
                          ? Icons.logout
                          : Icons.login,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      authController.isAuthenticated ? 'Salir' : 'Iniciar Sesión',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0d0d0d),
                    Color(0xFF1a1a2e),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF0d0d0d),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ANTHONY CORDOVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (authController.userEmail != null)
                    Text(
                      authController.userEmail!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
                _navigateToRoute('/');
              },
              isSelected: _selectedIndex == 0,
            ),
            _DrawerItem(
              icon: Icons.work,
              title: 'Projects',
              onTap: () {
                Navigator.pop(context);
                _navigateToRoute('/project');
              },
              isSelected: _selectedIndex == 1,
            ),
            _DrawerItem(
              icon: Icons.school,
              title: 'Certifications',
              onTap: () {
                Navigator.pop(context);
                _navigateToRoute('/certification');
              },
              isSelected: _selectedIndex == 2,
            ),
            _DrawerItem(
              icon: Icons.mail,
              title: 'Contact',
              onTap: () {
                Navigator.pop(context);
                _navigateToRoute('/contact');
              },
              isSelected: _selectedIndex == 3,
            ),
            Divider(color: Colors.grey[300]),
            _DrawerItem(
              icon: Icons.info,
              title: 'About Me',
              onTap: () {
                Navigator.pop(context);
                context.go('/aboutme');
              },
            ),
            // Solo mostrar opciones de upload si está autenticado
            if (authController.isAuthenticated) ...[
              _DrawerItem(
                icon: Icons.upload,
                title: 'Upload Project',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/uploadproject');
                },
              ),
              _DrawerItem(
                icon: Icons.upload_file,
                title: 'Upload Certification',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/uploadcertification');
                },
              ),
            ],
            Divider(color: Colors.grey[300]),
            // Login/Logout
            _DrawerItem(
              icon: authController.isAuthenticated ? Icons.logout : Icons.login,
              title: authController.isAuthenticated ? 'Logout' : 'Login',
              onTap: () {
                Navigator.pop(context);
                if (authController.isAuthenticated) {
                  _handleLogout();
                } else {
                  _handleLogin();
                }
              },
              isSelected: false,
            ),
          ],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF0d0d0d),
        selectedItemColor: Color(0xFF9c27b0),
        unselectedItemColor: Colors.grey[400],
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFF9c27b0) : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(0xFF9c27b0) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
      tileColor: isSelected ? Color(0xFF9c27b0).withOpacity(0.1) : null,
    );
  }
}
