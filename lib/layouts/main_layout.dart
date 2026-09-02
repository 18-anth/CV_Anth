import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cv_anth/main.dart' show authController;
import 'package:cv_anth/view/Auth/LoginScreen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;

  const MainLayout({super.key, required this.child, this.currentRoute});

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
  }

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
    if (mounted) setState(() {});
  }

  String _getAppBarTitle() {
    switch (widget.currentRoute) {
      case '/':
        return 'Home ';
      case '/project':
        return 'Projects ';
      case '/certification':
        return 'Certifications ';
      case '/aboutme':
        return 'About Me ';
      case '/contact':
        return 'Contact ';
      case '/terms':
        return 'Terms of Use';
      case '/privacy':
        return 'Privacy Policy';
      default:
        return 'CV { Anth }';
    }
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
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.blackOption,
        toolbarTextStyle: TextStyle(
          color: AppColors.blackOption,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.blackOption,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
                      authController.isAuthenticated
                          ? 'Salir'
                          : 'Iniciar Sesión',
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
                  colors: [AppColors.blackOption, AppColors.darkgrey],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkgrey,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/img/yotraje.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.light,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    authController.isAuthenticated
                        ? (authController.userEmail
                                  ?.split('@')
                                  .first
                                  .toUpperCase() ??
                              'ADMIN')
                        : 'PORTFOLIO',
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (authController.isAuthenticated &&
                      authController.userEmail != null)
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        authController.userEmail!,
                        style: TextStyle(
                          color: AppColors.light.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    )
                  else if (!authController.isAuthenticated)
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        'Login para más',
                        style: TextStyle(
                          color: AppColors.light.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
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

            _DrawerItem(
              icon: Icons.info,
              title: 'About Me',
              onTap: () {
                Navigator.pop(context);
                context.go('/aboutme');
              },
            ),
            _DrawerItem(
              icon: Icons.description,
              title: 'Terms of Use',
              onTap: () {
                Navigator.pop(context);
                context.go('/terms');
              },
            ),
            _DrawerItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.pop(context);
                context.go('/privacy');
              },
            ),
            // Solo mostrar opciones de upload si está autenticado
            if (authController.isAuthenticated) ...[
              Divider(color: Colors.grey[300]),
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
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.blackOption,
        elevation: 0,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Contact'),
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
        color: isSelected ? AppColors.blackOption : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.blackOption : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
      tileColor: isSelected
          ? AppColors.blackOption.withValues(alpha: 0.1)
          : null,
    );
  }
}
