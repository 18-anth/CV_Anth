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

            const SizedBox(height: 60),

            // Segunda sección: Lista de certificaciones
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white.withOpacity(0.02)],
                ),
              ),
              child: Column(
                children: [
                  // Encabezado de la sección
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'CERTIFICACIONES Y CURSOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            width: 60,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido de certificaciones
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Cargando certificaciones...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Error: $errorMessage',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (certifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(60),
                      child: Text(
                        'No hay certificaciones disponibles.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                        vertical: 20,
                      ),
                      child: Wrap(
                        spacing: isMobile ? 16 : 28,
                        runSpacing: isMobile ? 20 : 32,
                        alignment: WrapAlignment.center,
                        children: List.generate(certifications.length, (index) {
                          final displayIndex = order[index];
                          final cert = certifications[displayIndex];
                          final itemWidth = isMobile
                              ? double.infinity
                              : isTablet
                              ? (MediaQuery.of(context).size.width - 96) / 2
                              : (MediaQuery.of(context).size.width - 128) / 3;

                          return _CertificationCard(
                            cert: cert,
                            itemWidth: itemWidth,
                            animationDelay: Duration(milliseconds: index * 100),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
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
              final scale = 1.0 + (_hoverController.value * 0.03);
              final translateY = -(_hoverController.value * 8);
              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: () => context.go('/certification/${widget.cert.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.15),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.school_rounded,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.cert.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    if (widget.cert.description.isNotEmpty)
                                      Text(
                                        widget.cert.description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.3,
                                          height: 1.5,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Ver detalles',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
