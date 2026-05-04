import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/upload_certification_controller.dart';
import '../../utils/Colors.dart';
import '../../widgets/UploadCertification/upload_uploading_widget.dart';
import '../../widgets/UploadCertification/upload_pdf_selector.dart';
import '../../widgets/UploadCertification/upload_logo_selector.dart';
import '../../widgets/UploadCertification/upload_user_info_banner.dart';
import '../../widgets/UploadCertification/upload_auth_dialog.dart';

class UploadCertification extends StatefulWidget {
  const UploadCertification({super.key});

  @override
  State<UploadCertification> createState() => _UploadCertificationState();
}

class _UploadCertificationState extends State<UploadCertification> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _seriesController = TextEditingController();
  final _linkController = TextEditingController();

  final _controller = UploadCertificationController();

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _linkController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCertification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_controller.pdfFile == null) {
      _showError('Por favor selecciona un archivo PDF');
      return;
    }

    try {
      await _controller.saveCertification(
        name: _nameController.text.trim(),
        series: _seriesController.text.trim(),
        link: _linkController.text.trim(),
        showAuthInstructions: () => showUploadAuthInstructionsDialog(context),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Certificación creada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/certification');
    } catch (e) {
      _controller.resetUpload();

      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('POPUP_CERRADO') ||
          errorStr.contains('popup_closed')) {
        errorMessage =
            '❌ Se cerró la ventana de Google.\n\nPor favor, autoriza el acceso a Google Drive para poder subir el PDF.';
      } else if (errorStr.contains('AUTENTICACION_CANCELADA')) {
        errorMessage =
            '❌ Autenticación cancelada.\n\nNecesitas autorizar el acceso a Google Drive para subir el PDF.';
      } else if (errorStr.contains('NetworkError') ||
          errorStr.contains('network')) {
        errorMessage =
            '❌ Error de conexión.\n\nVerifica tu conexión a internet e intenta nuevamente.';
      } else {
        errorMessage = 'Error al guardar certificación: $e';
      }

      _showError(errorMessage);
    }
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

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (!authController.isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(isUploading: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Debes iniciar sesión para subir certificaciones',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Iniciar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(isUploading: _controller.isUploading),
          body: _controller.isUploading
              ? UploadUploadingWidget(
                  uploadStatus: _controller.uploadStatus,
                  uploadProgress: _controller.uploadProgress,
                )
              : _buildForm(isMobile),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar({required bool isUploading}) {
    return AppBar(
      title: const Text('Subir Certificación'),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0d0d0d),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: isUploading ? null : () => context.go('/certification'),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info del usuario
                const UploadUserInfoBanner(),
                const SizedBox(height: 30),

                // Título de la sección
                const Text(
                  '📜 Información de la Certificación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo: Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    label: 'Nombre de la Certificación',
                    hint: "Ej: CS50's Introduction to Computer Science",
                    icon: Icons.card_membership,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                  maxLength: 150,
                ),
                const SizedBox(height: 20),

                // Campo: Serie del curso
                TextFormField(
                  controller: _seriesController,
                  decoration: _inputDecoration(
                    label: 'Serie del Curso (opcional)',
                    hint: 'Ej: CS50x',
                    icon: Icons.numbers,
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 20),

                // Campo: Link (opcional)
                TextFormField(
                  controller: _linkController,
                  decoration: _inputDecoration(
                    label: 'Link del Certificado (opcional)',
                    hint: 'Ej: https://courses.edx.org/certificates/...',
                    icon: Icons.link,
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 30),

                // Sección de logos
                const Text(
                  '🏷️ Logos (opcional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 15),

                // Logo de plataforma
                UploadLogoSelector(
                  title: 'Logo de Plataforma',
                  subtitle: 'Ej: edX, Coursera, Udemy',
                  file: _controller.platformLogo,
                  onPick: _controller.pickPlatformLogo,
                  onRemove: _controller.removePlatformLogo,
                ),
                const SizedBox(height: 15),

                // Logo de institución
                UploadLogoSelector(
                  title: 'Logo de Institución/Empresa',
                  subtitle: 'Ej: Harvard, Stanford, Google',
                  file: _controller.institutionLogo,
                  onPick: _controller.pickInstitutionLogo,
                  onRemove: _controller.removeInstitutionLogo,
                ),
                const SizedBox(height: 30),

                // Sección de archivo PDF
                const Text(
                  '📄 Archivo PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 15),

                // Selector de PDF
                UploadPdfSelector(
                  pdfFile: _controller.pdfFile,
                  onPick: _controller.pickPdf,
                  onRemove: _controller.removePdf,
                ),
                const SizedBox(height: 40),

                // Botón de guardar
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _saveCertification,
                    icon: const Icon(Icons.cloud_upload, size: 24),
                    label: const Text(
                      'Subir Certificación',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0d0d0d),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
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
