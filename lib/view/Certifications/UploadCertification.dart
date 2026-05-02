import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../services/google_drive_upload_service.dart';
import '../../utils/Colors.dart';

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

  PlatformFile? _pdfFile;
  PlatformFile? _platformLogo;
  PlatformFile? _institutionLogo;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA SELECCIONAR PDF
  // ══════════════════════════════════════════════════════════════

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pdfFile = result.files.first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar PDF: $e');
    }
  }

  void _removePdf() {
    setState(() {
      _pdfFile = null;
    });
  }

  Future<void> _pickPlatformLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _platformLogo = result.files.first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar logo de plataforma: $e');
    }
  }

  void _removePlatformLogo() {
    setState(() {
      _platformLogo = null;
    });
  }

  Future<void> _pickInstitutionLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _institutionLogo = result.files.first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar logo de institución: $e');
    }
  }

  void _removeInstitutionLogo() {
    setState(() {
      _institutionLogo = null;
    });
  }

  // ══════════════════════════════════════════════════════════════
  // DIÁLOGO DE INSTRUCCIONES DE AUTENTICACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<bool> _showAuthInstructions() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text('Autorización de Google Drive'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se abrirá una ventana emergente de Google para autorizar el acceso a Google Drive.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Por favor, sigue estos pasos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                _buildInstructionStep(
                  '1',
                  'Espera a que se abra la ventana de Google',
                ),
                _buildInstructionStep('2', 'Selecciona tu cuenta de Google'),
                _buildInstructionStep('3', 'Haz clic en "Permitir" o "Allow"'),
                _buildInstructionStep('4', 'NO cierres la ventana manualmente'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Si cierras la ventana, la subida se cancelará',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check),
                label: const Text('Entendido, continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA GUARDAR LA CERTIFICACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<void> _saveCertification() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya un PDF
    if (_pdfFile == null) {
      _showError('Debes seleccionar un archivo PDF');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Conectando con Google Drive...';
    });

    try {
      // 0. Mostrar instrucciones antes de autenticar
      if (!mounted) return;
      final shouldContinue = await _showAuthInstructions();
      if (!shouldContinue) {
        setState(() => _isUploading = false);
        return;
      }

      // 1. Pre-autenticar con Google Drive
      setState(() => _uploadStatus = 'Autenticando con Google Drive...');
      final authenticated = await GoogleDriveUploadService.preAuthenticate();

      if (!authenticated) {
        throw Exception('AUTENTICACION_CANCELADA');
      }

      // 2. Generar ID de la certificación
      final certificationId = FirebaseService.generateUUID();

      // 3. Subir PDF a Google Drive (subcarpeta 'pdf')
      setState(() {
        _uploadProgress = 0.2;
        _uploadStatus = 'Subiendo PDF a Google Drive...';
      });

      final pdfUrl = await GoogleDriveUploadService.uploadImage(
        projectId: certificationId,
        type: 'certification',
        file: _pdfFile!,
        subFolder: 'pdf',
      );

      setState(() {
        _uploadProgress = 0.4;
        _uploadStatus = 'PDF subido correctamente';
      });

      // 4. Subir logo de plataforma (subcarpeta 'logos')
      String? platformLogoUrl;
      if (_platformLogo != null) {
        setState(() {
          _uploadProgress = 0.5;
          _uploadStatus = 'Subiendo logo de plataforma...';
        });

        platformLogoUrl = await GoogleDriveUploadService.uploadImage(
          projectId: certificationId,
          type: 'certification',
          file: _platformLogo!,
          subFolder: 'logos',
        );
      }

      // 5. Subir logo de institución (subcarpeta 'logos')
      String? institutionLogoUrl;
      if (_institutionLogo != null) {
        setState(() {
          _uploadProgress = 0.6;
          _uploadStatus = 'Subiendo logo de institución...';
        });

        institutionLogoUrl = await GoogleDriveUploadService.uploadImage(
          projectId: certificationId,
          type: 'certification',
          file: _institutionLogo!,
          subFolder: 'logos',
        );
      }

      // 6. Guardar en Firebase Realtime Database
      setState(() {
        _uploadProgress = 0.8;
        _uploadStatus = 'Guardando certificación en base de datos...';
      });

      await FirebaseService.saveCertification(
        id: certificationId,
        name: _nameController.text.trim(),
        pdfUrl: pdfUrl,
        series: _seriesController.text.trim().isNotEmpty
            ? _seriesController.text.trim()
            : null,
        link: _linkController.text.trim().isNotEmpty
            ? _linkController.text.trim()
            : null,
        platformLogoUrl: platformLogoUrl,
        institutionLogoUrl: institutionLogoUrl,
      );

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = '¡Certificación guardada exitosamente!';
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Certificación creada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Esperar un momento y regresar
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/certification');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      // Mensajes de error más amigables
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
        appBar: _buildAppBar(),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isUploading ? _buildUploadingWidget() : _buildForm(isMobile),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Subir Certificación'),
      backgroundColor: const Color(0xFF0d0d0d),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isUploading ? null : () => context.go('/certification'),
      ),
    );
  }

  Widget _buildUploadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
            const SizedBox(height: 30),
            Text(
              _uploadStatus,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
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
                _buildUserInfo(),
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
                    hint: 'Ej: CS50\'s Introduction to Computer Science',
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
                _buildLogoSelector(
                  title: 'Logo de Plataforma',
                  subtitle: 'Ej: edX, Coursera, Udemy',
                  file: _platformLogo,
                  onPick: _pickPlatformLogo,
                  onRemove: _removePlatformLogo,
                ),
                const SizedBox(height: 15),

                // Logo de institución
                _buildLogoSelector(
                  title: 'Logo de Institución/Empresa',
                  subtitle: 'Ej: Harvard, Stanford, Google',
                  file: _institutionLogo,
                  onPick: _pickInstitutionLogo,
                  onRemove: _removeInstitutionLogo,
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
                _buildPdfSelector(),
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

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0d0d0d), Color(0xFF1a1a1a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subiendo como Administrador',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Certificación visible públicamente',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user, color: Colors.greenAccent, size: 26),
        ],
      ),
    );
  }

  Widget _buildPdfSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_pdfFile == null) ...[
            Icon(Icons.picture_as_pdf, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 15),
            const Text(
              'Selecciona un archivo PDF',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d0d0d),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pdfFile!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFileSize(_pdfFile!.size),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removePdf,
                  tooltip: 'Eliminar PDF',
                ),
              ],
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.edit),
              label: const Text('Cambiar PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0d0d0d),
                side: const BorderSide(color: Color(0xFF0d0d0d)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoSelector({
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0d0d0d),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 15),
          if (file == null) ...[
            Center(
              child: ElevatedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text('Seleccionar Logo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: const Color(0xFF0d0d0d),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: file.bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(file.bytes!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFileSize(file.size),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Cambiar Logo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0d0d0d),
                  side: const BorderSide(color: Color(0xFF0d0d0d)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
