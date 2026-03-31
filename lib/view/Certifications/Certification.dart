import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_database/firebase_database.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../models/BookModel.dart';

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

  factory CertificationModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return CertificationModel(
      id: id,
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

class _CertificationState extends State<Certification>
    with TickerProviderStateMixin {
  List<CertificationModel> certifications = [];
  List<int> order = [];
  late AnimationController _dragController;
  int? draggedIndex;
  double dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCertifications();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _loadCertifications() {
    try {
      final database = FirebaseDatabase.instance;
      final certRef = database.ref('Certifications');

      certRef.onValue.listen(
        (DatabaseEvent event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            final certList = <CertificationModel>[];
            data.forEach((key, value) {
              certList.add(CertificationModel.fromMap(key, value));
            });
            setState(() {
              certifications = certList;
              order = List.generate(certifications.length, (i) => i);
            });
          }
        },
        onError: (error) {
          print('Error loading certifications: $error');
        },
      );
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  void _handleDragUpdate(int index, DragUpdateDetails details) {
    setState(() {
      draggedIndex = index;
      dragOffset = details.localPosition.dy;
    });
  }

  void _handleDragEnd(int index) {
    _dragController.forward().then((_) {
      setState(() {
        draggedIndex = null;
        dragOffset = 0;
      });
      _dragController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Primera sección: Título y modelo
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Color(0xFF010103).withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
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

            // Segunda sección: Lista de certificaciones
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0d0d0d), Color(0xFF1a1a2e)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
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
                      width: 250,
                      height: 250,
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
                      if (certifications.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              'Cargando certificaciones...',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : (3),
                                childAspectRatio: 1.6 / 1,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                          itemCount: certifications.length,
                          itemBuilder: (context, index) {
                            final displayIndex = order[index];
                            final cert = certifications[displayIndex];
                            final isDragged = draggedIndex == index;

                            return FadeInUp(
                              delay: Duration(milliseconds: index * 100),
                              duration: const Duration(milliseconds: 800),
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) =>
                                    _handleDragUpdate(index, details),
                                onVerticalDragEnd: (_) => _handleDragEnd(index),
                                child: MouseRegion(
                                  onEnter: (_) => _dragController.forward(),
                                  onExit: (_) => _dragController.reverse(),
                                  child: AnimatedBuilder(
                                    animation: _dragController,
                                    builder: (context, child) {
                                      double scale =
                                          1.0 + (_dragController.value * 0.05);
                                      if (isDragged) {
                                        scale = 1.0 + (dragOffset.abs() / 500);
                                      }

                                      return Transform.scale(
                                        scale: scale,
                                        child: GestureDetector(
                                          onTap: () {
                                            context.go(
                                              '/certification/${cert.id}',
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(
                                                    0.05,
                                                  ),
                                                  Colors.white.withOpacity(
                                                    0.02,
                                                  ),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.37),
                                                  blurRadius: 32,
                                                  spreadRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                // Backdrop filter effect con Container
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child: BackdropFilter(
                                                      filter:
                                                          ui.ImageFilter.blur(
                                                            sigmaX: 10,
                                                            sigmaY: 10,
                                                          ),
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Contenido
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cert.name,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          letterSpacing: 2,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset: Offset(
                                                                2,
                                                                2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        'Ver certificado',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'Courier New',
                                                          letterSpacing: 4,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset: Offset(
                                                                2,
                                                                2,
                                                              ),
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
                          },
                        ),
                      SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
