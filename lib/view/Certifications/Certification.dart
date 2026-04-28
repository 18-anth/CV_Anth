import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../models/BookModel.dart';
import '../../services/firebase_service.dart';

class CertificationModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  CertificationModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory CertificationModel.fromMap(Map<String, dynamic> data) {
    return CertificationModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? 'Sin nombre',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}

class Certification extends StatefulWidget {
  const Certification({super.key});

  @override
  State<Certification> createState() => _CertificationState();
}

class _CertificationState extends State<Certification> {
  List<CertificationModel> certifications = [];
  List<int> order = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    try {
      final data = await FirebaseService.fetchCertifications();
      if (!mounted) return;
      setState(() {
        certifications = data
            .map((e) => CertificationModel.fromMap(e))
            .toList();
        order = List.generate(certifications.length, (i) => i);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando certificaciones: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Primera sección: Título y modelo
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
                    // Modelo 3D Libro
                    Positioned(
                      child: SizedBox(
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.8
                            : isTablet
                            ? MediaQuery.of(context).size.width * 0.6
                            : MediaQuery.of(context).size.width * 0.4,
                        height: 300,
                        child: const BookModel(),
                      ),
                    ),
                    // Texto "COURSES"
                    Center(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        from: 20,
                        child: Text(
                          'COURSES',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF4F4F4),
                            fontSize: isMobile
                                ? 48
                                : isTablet
                                ? 80
                                : 120,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(2, 2),
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

            const SizedBox(height: 40),

            // Segunda sección: Lista de certificaciones
            Stack(
              children: [
                // Círculos decorativos
                Positioned(
                  top: 20,
                  left: 30,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Lista de certificaciones
                Column(
                  children: [
                    SizedBox(height: 40),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.white54),
                              SizedBox(height: 16),
                              Text(
                                'Cargando certificaciones...',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'Error: $errorMessage',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (certifications.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No hay certificaciones disponibles.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: List.generate(certifications.length, (index) {
                            final displayIndex = order[index];
                            final cert = certifications[displayIndex];
                            final itemWidth = isMobile
                                ? double.infinity
                                : isTablet
                                ? (MediaQuery.of(context).size.width - 68) / 2
                                : (MediaQuery.of(context).size.width - 68) / 3;

                            return _CertificationCard(
                              cert: cert,
                              itemWidth: itemWidth,
                              animationDelay: Duration(milliseconds: index * 100),
                            );
                          }),
                        ),
                      ),
                    SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationCard extends StatefulWidget {
  final CertificationModel cert;
  final double itemWidth;
  final Duration animationDelay;

  const _CertificationCard({
    required this.cert,
    required this.itemWidth,
    required this.animationDelay,
  });

  @override
  State<_CertificationCard> createState() => _CertificationCardState();
}

class _CertificationCardState extends State<_CertificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.itemWidth,
      child: FadeInUp(
        delay: widget.animationDelay,
        duration: const Duration(milliseconds: 800),
        child: MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              final scale = 1.0 + (_hoverController.value * 0.05);
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: () => context.go('/certification/${widget.cert.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.black.withOpacity(0.85),
                          AppColors.blackOption,
                          Colors.black,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Efecto espejo: reflejo superior
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.04),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Backdrop blur
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ),
                        // Contenido
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.cert.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ver certificado',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'Courier New',
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
