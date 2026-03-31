import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';

class CertificationDetail extends StatefulWidget {
  final String certificationId;

  const CertificationDetail({
    super.key,
    required this.certificationId,
  });

  @override
  State<CertificationDetail> createState() => _CertificationDetailState();
}

class _CertificationDetailState extends State<CertificationDetail> {
  Map<dynamic, dynamic>? certification;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertification();
  }

  void _loadCertification() {
    try {
      final database = FirebaseDatabase.instance;
      final certRef = database.ref('Certifications/${widget.certificationId}');

      certRef.get().then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            certification = snapshot.value as Map<dynamic, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Certificación no encontrada';
            isLoading = false;
          });
        }
      }).catchError((error) {
        setState(() {
          errorMessage = 'Error al cargar: $error';
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: Center(
          child: Text(
            errorMessage ?? 'Error desconocido',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (certification == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: const Center(
          child: Text('No hay datos disponibles'),
        ),
      );
    }

    final name = certification?['name'] ?? 'Sin nombre';
    final pdfUrl = certification?['pdfUrl'] ?? '';
    final description = certification?['description'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Certificación'),
        backgroundColor: const Color(0xFF0d0d0d),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/certification'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Título
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF050A30),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // PDF Viewer
            if (pdfUrl.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pdfUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              const Text('No se pudo cargar la imagen'),
                              const SizedBox(height: 16),
                              if (pdfUrl.isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Aquí puedes agregar lógica para abrir el PDF en una app externa
                                    // o en un visor de PDF si lo deseas
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Abrir PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF050A30),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay PDF disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/certification'),
        backgroundColor: const Color(0xFF040404),
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_back, color: Color(0xFFF4F4F4)),
      ),
    );
  }
}
