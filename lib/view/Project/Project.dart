import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/RobotModel.dart';
import '../../services/firebase_service.dart';
import '../../controllers/auth_controller.dart';

class ProjectCard {
  final String id;
  final String name;
  final String description;
  final int timestamp;
  final String? logo;

  ProjectCard({
    required this.id,
    required this.name,
    required this.description,
    required this.timestamp,
    this.logo,
  });

  factory ProjectCard.fromMap(Map<String, dynamic> data) {
    int timestamp = 0;
    final rawTimestamp = data['timestamp'];

    if (rawTimestamp is int) {
      timestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      try {
        final dateTime = DateTime.parse(rawTimestamp);
        timestamp = dateTime.millisecondsSinceEpoch;
      } catch (e) {
        timestamp = 0;
      }
    }

    return ProjectCard(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? 'Sin nombre',
      description: data['description'] ?? '',
      timestamp: timestamp,
      logo: data['logo'] as String?,
    );
  }
}

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  List<ProjectCard> cardsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final data = await FirebaseService.fetchProjects();
      if (!mounted) return;
      setState(() {
        cardsData = data.map((e) => ProjectCard.fromMap(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  /// Convierte URLs de Google Drive al formato correcto que evita problemas de CORS
  /// Usa lh3.googleusercontent.com que permite acceso directo sin CORS
  String _fixGoogleDriveUrl(String url) {
    if (url.isEmpty) return url;

    // Si ya es el formato correcto (lh3.googleusercontent.com), devolverla sin cambios
    if (url.contains('lh3.googleusercontent.com/d/')) {
      return url;
    }

    // Extraer el ID del archivo de diferentes formatos de URLs de Google Drive
    // Soporta:
    // - https://drive.usercontent.google.com/download?id=FILE_ID
    // - https://drive.google.com/uc?export=view&id=FILE_ID
    // - https://drive.google.com/file/d/FILE_ID/view
    // - https://www.googleapis.com/drive/v3/files/FILE_ID
    RegExp regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
    Match? match = regExp.firstMatch(url);

    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      // Convertir al formato que funciona sin CORS
      // lh3.googleusercontent.com sirve contenido directamente sin redirecciones
      return 'https://lh3.googleusercontent.com/d/$fileId';
    }

    // Si no es una URL de Google Drive, devolverla sin cambios
    return url;
  }

  void _shareProject(ProjectCard card) async {
    try {
      await Share.share(
        'Mira este proyecto: ${card.name}. Este proyecto podría interesarte:',
        subject: 'Mira este proyecto',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section con modelo 3D
          Container(
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Modelo 3D Robot
                  Positioned(
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.8
                          : isTablet
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width * 0.4,
                      height: 400,
                      child: const RobotModel(),
                    ),
                  ),
                  // Texto "PROJECTS"
                  Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      from: 20,
                      child: Text(
                        'PROJECTS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF4F4F4),
                          fontSize: isMobile
                              ? 48
                              : isTablet
                              ? 80
                              : 120,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sección de tarjetas
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Botón para agregar proyecto (solo si está autenticado)
                _buildAddProjectButton(),
                const SizedBox(height: 20),

                // Grid de proyectos
                isLoading
                    ? const CircularProgressIndicator()
                    : cardsData.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('No hay proyectos disponibles'),
                        ),
                      )
                    : _buildProjectGrid(isMobile, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(bool isMobile, bool isTablet) {
    int crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SlideInLeft(
            duration: const Duration(milliseconds: 600),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final colWidth =
                    (constraints.maxWidth - 16.0 * (crossAxisCount - 1)) /
                    crossAxisCount;
                final columns = List.generate(
                  crossAxisCount,
                  (_) => <Widget>[],
                );
                for (int i = 0; i < cardsData.length; i++) {
                  columns[i % crossAxisCount].add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildProjectCard(cardsData[i], i),
                    ),
                  );
                }
                final rowChildren = <Widget>[];
                for (int col = 0; col < crossAxisCount; col++) {
                  if (col > 0) rowChildren.add(const SizedBox(width: 16));
                  rowChildren.add(
                    SizedBox(
                      width: colWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: columns[col],
                      ),
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rowChildren,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Paleta de acentos por índice para dar identidad visual a cada tarjeta
  static const List<List<Color>> _cardGradients = [
    [Color(0xFFB8C6DB), Color(0xFFA8B8CC)],
    [Color(0xFFB5CCBA), Color(0xFFA3BFA8)],
    [Color(0xFFD6C5E0), Color(0xFFC4B0D4)],
    [Color(0xFFD4C5B0), Color(0xFFC8B89A)],
    [Color(0xFFB0C8D4), Color(0xFF9BBAC6)],
    [Color(0xFFD4B0B8), Color(0xFFC49AA3)],
  ];

  Widget _buildProjectCard(ProjectCard card, int index) {
    final gradient = _cardGradients[index % _cardGradients.length];

    return FadeInUp(
      from: 60,
      delay: Duration(milliseconds: 80 * index),
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => context.go('/project/${card.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner superior con gradiente
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono + nombre
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: (card.logo != null && card.logo!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _fixGoogleDriveUrl(card.logo!),
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.code_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            );
                                          },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.code_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              card.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Descripción
                      Text(
                        card.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider sutil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.15),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.grey.withOpacity(0.6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(card.timestamp),
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Botón compartir
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _shareProject(card),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.ios_share_rounded,
                              size: 18,
                              color: const Color(0xFF7A8FA6),
                            ),
                          ),
                        ),
                      ),
                      // Botón ver proyecto
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Ver más',
                          style: TextStyle(
                            color: Color(0xFF4A5568),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOTÓN PARA AGREGAR PROYECTO (solo si está autenticado)
  // ══════════════════════════════════════════════════════════════

  Widget _buildAddProjectButton() {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        // Solo mostrar si el usuario está autenticado
        if (!auth.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF050A30), Color(0xFF0d0d0d)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go('/uploadproject'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Agregar Nuevo Proyecto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sube tus proyectos con imágenes y enlaces',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
