import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/edit_certification_controller.dart';
import '../../services/firebase_service.dart';
import '../../widgets/EditCertification/edit_uploading_widget.dart';
import '../../widgets/EditCertification/edit_pdf_selector.dart';
import '../../widgets/EditCertification/edit_logo_selector.dart';
import '../../widgets/EditCertification/edit_user_info_banner.dart';
import '../../widgets/EditCertification/edit_auth_dialog.dart';

class EditCertification extends StatefulWidget {
  final String certificationId;

  const EditCertification({super.key, required this.certificationId});

  @override
  State<EditCertification> createState() => _EditCertificationState();
}

class _EditCertificationState extends State<EditCertification> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _seriesController = TextEditingController();
  final _linkController = TextEditingController();

  late final EditCertificationController _controller;
  List<String> availableCategories = [];
  String? selectedCategory;
  bool categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = EditCertificationController();
    Future.wait([
      _loadCertification(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await FirebaseService.fetchCertificationCategories();
      if (mounted) {
        setState(() {
          availableCategories = categories;
          categoriesLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
      if (mounted) {
        setState(() {
          categoriesLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _seriesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadCertification() async {
    try {
      await _controller.loadCertification(widget.certificationId);
      if (!mounted) return;
      if (_controller.certification == null) {
        _showError('Certificación no encontrada');
        context.go('/certification');
        return;
      }
      final data = _controller.certification!;
      _nameController.text = data['name'] ?? '';
      _seriesController.text = data['series'] ?? '';
      _linkController.text = data['link'] ?? '';
      setState(() {
        selectedCategory = data['classification'] ?? availableCategories.firstOrNull;
      });
    } catch (e) {
      debugPrint('Error cargando certificación: $e');
      if (!mounted) return;
      _showError('Error al cargar la certificación: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA ACTUALIZAR LA CERTIFICACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_controller.pdfFile == null && _controller.currentPdfUrl == null) {
      _showError('Debes tener un archivo PDF');
      return;
    }

    if (selectedCategory == null) {
      _showError('Por favor selecciona una categoría');
      return;
    }

    try {
      await _controller.updateCertification(
        certificationId: widget.certificationId,
        name: _nameController.text.trim(),
        series: _seriesController.text.trim(),
        link: _linkController.text.trim(),
        classification: selectedCategory ?? '',
        showAuthInstructions: () => showAuthInstructionsDialog(context),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificación actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/certification/${widget.certificationId}');
    } catch (e) {
      _controller.resetUpload();
      _showError(_getErrorMessage(e.toString()));
    }
  }

  String _getErrorMessage(String errorStr) {
    if (errorStr.contains('POPUP_CERRADO') ||
        errorStr.contains('popup_closed_by_user')) {
      return 'La ventana de autenticación fue cerrada. Por favor, inténtalo nuevamente y no cierres la ventana hasta completar el proceso.';
    } else if (errorStr.contains('AUTENTICACION_CANCELADA')) {
      return 'Autenticación cancelada por el usuario.';
    } else if (errorStr.contains('NetworkError') ||
        errorStr.contains('network')) {
      return 'Error de conexión. Verifica tu internet e inténtalo nuevamente.';
    }
    return 'Error al actualizar: $errorStr';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UI
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Verificar autenticación
    if (!authController.isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Editar Certificación'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0d0d0d),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Debes iniciar sesión para editar certificaciones',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Iniciar Sesión'),
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Editar Certificación'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0d0d0d),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: _controller.isUploading
              ? EditUploadingWidget(
                  uploadStatus: _controller.uploadStatus,
                  uploadProgress: _controller.uploadProgress,
                )
              : _buildForm(isMobile),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Editar Certificación'),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0d0d0d),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _controller.isUploading
            ? null
            : () => context.go('/certification/${widget.certificationId}'),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información del usuario
                EditUserInfoBanner(
                  certificationName:
                      _controller.certification?['name'] ?? 'Sin nombre',
                ),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Actualizar Certificación',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Modifica los campos que desees actualizar',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Campo: Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    label: 'Nombre de la Certificación',
                    hint: 'Ej: Curso de Flutter Avanzado',
                    icon: Icons.school,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Serie/Número
                TextFormField(
                  controller: _seriesController,
                  decoration: _inputDecoration(
                    label: 'Serie o Número (Opcional)',
                    hint: 'Ej: ABC123456',
                    icon: Icons.confirmation_number,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo: Link
                TextFormField(
                  controller: _linkController,
                  decoration: _inputDecoration(
                    label: 'Link del Certificado (Opcional)',
                    hint: 'https://...',
                    icon: Icons.link,
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.startsWith('http')) {
                      return 'Debe ser una URL válida (http:// o https://)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Categoría
                if (categoriesLoading)
                  const SizedBox(
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (availableCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No hay categorías disponibles',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: _inputDecoration(
                      label: 'Categoría de Certificación',
                      hint: 'Selecciona una categoría',
                      icon: Icons.category,
                    ),
                    items: availableCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La categoría es requerida';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 32),

                // Selector de PDF
                EditPdfSelector(
                  pdfFile: _controller.pdfFile,
                  currentPdfUrl: _controller.currentPdfUrl,
                  onPick: _controller.pickPdf,
                  onRemove: _controller.removePdf,
                ),
                const SizedBox(height: 24),

                // Selector de logo de plataforma
                EditLogoSelector(
                  title: 'Logo de Plataforma',
                  subtitle: 'Logo de la plataforma (Ej: Udemy, Coursera)',
                  file: _controller.platformLogo,
                  currentUrl: _controller.currentPlatformLogoUrl,
                  onPick: _controller.pickPlatformLogo,
                  onRemove: _controller.removePlatformLogo,
                ),
                const SizedBox(height: 24),

                // Selector de logo de institución
                EditLogoSelector(
                  title: 'Logo de Institución',
                  subtitle: 'Logo de la institución emisora',
                  file: _controller.institutionLogo,
                  currentUrl: _controller.currentInstitutionLogoUrl,
                  onPick: _controller.pickInstitutionLogo,
                  onRemove: _controller.removeInstitutionLogo,
                ),
                const SizedBox(height: 32),

                // Botón Actualizar
                ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d0d0d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text(
                        'Actualizar Certificación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF0d0d0d)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0d0d0d), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
