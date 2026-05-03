import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../services/google_drive_upload_service.dart';

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

  PlatformFile? _pdfFile;
  PlatformFile? _platformLogo;
  PlatformFile? _institutionLogo;

  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  // URLs actuales de la certificación
  String? _currentPdfUrl;
  String? _currentPlatformLogoUrl;
  String? _currentInstitutionLogoUrl;

  Map<String, dynamic>? _certification;

  @override
  void initState() {
    super.initState();
    _loadCertification();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadCertification() async {
    try {
      final data =
          await FirebaseService.fetchCertificationById(widget.certificationId);
      if (data == null) {
        if (!mounted) return;
        _showError('Certificación no encontrada');
        context.go('/certification');
        return;
      }

      setState(() {
        _certification = data;
        _nameController.text = data['name'] ?? '';
        _seriesController.text = data['series'] ?? '';
        _linkController.text = data['link'] ?? '';
        _currentPdfUrl = data['pdfUrl'];
        _currentPlatformLogoUrl = data['platformLogoUrl'];
        _currentInstitutionLogoUrl = data['institutionLogoUrl'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando certificación: $e');
      if (!mounted) return;
      _showError('Error al cargar la certificación: $e');
      setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODOS PARA SELECCIONAR ARCHIVOS
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
      _currentPlatformLogoUrl = null;
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
      _currentInstitutionLogoUrl = null;
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
                SizedBox(width: 8),
                Text('Autorización de Google Drive'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para actualizar archivos en Google Drive:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildInstructionStep('1',
                    'Se abrirá una ventana emergente de Google para autenticación'),
                _buildInstructionStep('2',
                    'Selecciona tu cuenta de Google (@gmail.com)'),
                _buildInstructionStep(
                    '3', 'Presiona "Continuar" cuando se te pida autorización'),
                _buildInstructionStep(
                    '4', 'Acepta los permisos de Google Drive'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ NO cierres la ventana emergente hasta completar la autorización',
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continuar'),
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA ACTUALIZAR LA CERTIFICACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<void> _updateCertification() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya un PDF (nuevo o existente)
    if (_pdfFile == null && _currentPdfUrl == null) {
      _showError('Debes tener un archivo PDF');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparando actualización...';
    });

    try {
      String pdfUrl = _currentPdfUrl ?? '';
      String? platformLogoUrl = _currentPlatformLogoUrl;
      String? institutionLogoUrl = _currentInstitutionLogoUrl;

      // Si hay nuevos archivos, autenticar y subir
      if (_pdfFile != null || _platformLogo != null || _institutionLogo != null) {
        // 1. Mostrar instrucciones antes de autenticar
        if (!mounted) return;
        final shouldContinue = await _showAuthInstructions();
        if (!shouldContinue) {
          setState(() => _isUploading = false);
          return;
        }

        // 2. Pre-autenticar con Google Drive
        setState(() => _uploadStatus = 'Autenticando con Google Drive...');
        final authenticated = await GoogleDriveUploadService.preAuthenticate();

        if (!authenticated) {
          throw Exception('AUTENTICACION_CANCELADA');
        }

        // 3. Subir nuevo PDF si se seleccionó uno
        if (_pdfFile != null) {
          setState(() {
            _uploadProgress = 0.2;
            _uploadStatus = 'Subiendo nuevo PDF a Google Drive...';
          });

          pdfUrl = await GoogleDriveUploadService.uploadImage(
            projectId: widget.certificationId,
            type: 'pdf',
            file: _pdfFile!,
            subFolder: 'pdf',
          );

          setState(() {
            _uploadProgress = 0.4;
            _uploadStatus = 'PDF actualizado correctamente';
          });
        }

        // 4. Subir nuevo logo de plataforma si se seleccionó
        if (_platformLogo != null) {
          setState(() {
            _uploadProgress = 0.5;
            _uploadStatus = 'Subiendo logo de plataforma...';
          });

          platformLogoUrl = await GoogleDriveUploadService.uploadImage(
            projectId: widget.certificationId,
            type: 'platform_logo',
            file: _platformLogo!,
            subFolder: 'logos',
          );

          setState(() => _uploadProgress = 0.7);
        }

        // 5. Subir nuevo logo de institución si se seleccionó
        if (_institutionLogo != null) {
          setState(() {
            _uploadProgress = 0.75;
            _uploadStatus = 'Subiendo logo de institución...';
          });

          institutionLogoUrl = await GoogleDriveUploadService.uploadImage(
            projectId: widget.certificationId,
            type: 'institution_logo',
            file: _institutionLogo!,
            subFolder: 'logos',
          );

          setState(() => _uploadProgress = 0.9);
        }
      }

      // 6. Actualizar en Firebase
      setState(() {
        _uploadProgress = 0.95;
        _uploadStatus = 'Actualizando certificación en base de datos...';
      });

      await FirebaseService.saveCertification(
        id: widget.certificationId,
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
        _uploadStatus = '¡Certificación actualizada exitosamente!';
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificación actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Esperar un momento y regresar al detalle
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/certification/${widget.certificationId}');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      // Mensajes de error más amigables
      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('POPUP_CERRADO') ||
          errorStr.contains('popup_closed_by_user')) {
        errorMessage =
            'La ventana de autenticación fue cerrada. Por favor, inténtalo nuevamente y no cierres la ventana hasta completar el proceso.';
      } else if (errorStr.contains('AUTENTICACION_CANCELADA')) {
        errorMessage = 'Autenticación cancelada por el usuario.';
      } else if (errorStr.contains('NetworkError') ||
          errorStr.contains('network')) {
        errorMessage =
            'Error de conexión. Verifica tu internet e inténtalo nuevamente.';
      } else {
        errorMessage = 'Error al actualizar: ${e.toString()}';
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
        appBar: AppBar(
          title: const Text('Editar Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Editar Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
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
      title: const Text('Editar Certificación'),
      backgroundColor: const Color(0xFF0d0d0d),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isUploading
            ? null
            : () => context.go('/certification/${widget.certificationId}'),
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
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _uploadStatus,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información del usuario
                _buildUserInfo(),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
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
                const SizedBox(height: 32),

                // Selector de PDF
                _buildPdfSelector(),
                const SizedBox(height: 24),

                // Selector de logo de plataforma
                _buildLogoSelector(
                  title: 'Logo de Plataforma',
                  subtitle: 'Logo de la plataforma (Ej: Udemy, Coursera)',
                  file: _platformLogo,
                  currentUrl: _currentPlatformLogoUrl,
                  onPick: _pickPlatformLogo,
                  onRemove: _removePlatformLogo,
                ),
                const SizedBox(height: 24),

                // Selector de logo de institución
                _buildLogoSelector(
                  title: 'Logo de Institución',
                  subtitle: 'Logo de la institución emisora',
                  file: _institutionLogo,
                  currentUrl: _currentInstitutionLogoUrl,
                  onPick: _pickInstitutionLogo,
                  onRemove: _removeInstitutionLogo,
                ),
                const SizedBox(height: 32),

                // Botón Actualizar
                ElevatedButton(
                  onPressed: _updateCertification,
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

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0d0d0d),
            const Color(0xFF0d0d0d).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modo de Edición',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Editando certificación: ${_certification?['name'] ?? 'Sin nombre'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfSelector() {
    final hasCurrentPdf = _currentPdfUrl != null && _currentPdfUrl!.isNotEmpty;
    final hasNewPdf = _pdfFile != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Archivo PDF del Certificado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mostrar PDF actual si existe
          if (hasCurrentPdf && !hasNewPdf) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF actual',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ya tienes un PDF cargado. Puedes dejarlo o subir uno nuevo.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Mostrar nuevo PDF si se seleccionó
          if (hasNewPdf) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pdfFile!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFileSize(_pdfFile!.size),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removePdf,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón para seleccionar/cambiar PDF
          OutlinedButton.icon(
            onPressed: _pickPdf,
            icon: Icon(hasNewPdf ? Icons.refresh : Icons.upload_file),
            label: Text(hasNewPdf ? 'Cambiar PDF' : (hasCurrentPdf ? 'Subir nuevo PDF' : 'Seleccionar PDF')),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0d0d0d),
              side: const BorderSide(color: Color(0xFF0d0d0d)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSelector({
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required String? currentUrl,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasCurrentLogo = currentUrl != null && currentUrl.isNotEmpty;
    final hasNewLogo = file != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mostrar logo actual
          if (hasCurrentLogo && !hasNewLogo) ...[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      currentUrl,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: onRemove,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logo actual',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
          ],

          // Mostrar nuevo logo
          if (hasNewLogo) ...[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Stack(
                children: [
                  Center(
                    child: file.bytes != null
                        ? Image.memory(
                            file.bytes!,
                            height: 80,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.image, size: 40),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: onRemove,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nuevo logo: ${file.name}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
          ],

          // Botón para seleccionar/cambiar logo
          OutlinedButton.icon(
            onPressed: onPick,
            icon: Icon(hasNewLogo ? Icons.refresh : Icons.upload),
            label: Text(hasNewLogo
                ? 'Cambiar Logo'
                : (hasCurrentLogo ? 'Subir nuevo logo' : 'Seleccionar Logo')),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0d0d0d),
              side: const BorderSide(color: Color(0xFF0d0d0d)),
            ),
          ),
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
