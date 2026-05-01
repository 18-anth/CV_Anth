import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../services/google_drive_upload_service.dart';
import '../../utils/Colors.dart';

class UploadProject extends StatefulWidget {
  const UploadProject({super.key});

  @override
  State<UploadProject> createState() => _UploadProjectState();
}

class _UploadProjectState extends State<UploadProject> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  final List<PlatformFile> _webImages = [];
  final List<PlatformFile> _mobileImages = [];
  PlatformFile? _logo;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODOS PARA SELECCIONAR IMÁGENES
  // ══════════════════════════════════════════════════════════════

  Future<void> _pickWebImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _webImages.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imágenes web: $e');
    }
  }

  Future<void> _pickMobileImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _mobileImages.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imágenes mobile: $e');
    }
  }

  void _removeWebImage(int index) {
    setState(() {
      _webImages.removeAt(index);
    });
  }

  void _removeMobileImage(int index) {
    setState(() {
      _mobileImages.removeAt(index);
    });
  }

  Future<void> _pickLogo() async {
    try {
      // Usar FilePicker (funciona en todas las plataformas incluido web)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _logo = result.files.first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar logo: $e');
    }
  }

  void _removeLogo() {
    setState(() {
      _logo = null;
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
            _buildInstructionStep('1', 'Espera a que se abra la ventana de Google'),
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
    ) ?? false;
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
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA GUARDAR EL PROYECTO
  // ══════════════════════════════════════════════════════════════

  Future<void> _saveProject() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya al menos una imagen
    if (_webImages.isEmpty && _mobileImages.isEmpty) {
      _showError('Debes agregar al menos una imagen (web o mobile)');
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

      // 1. Generar ID del proyecto
      final projectId = FirebaseService.generateUUID();

      // 1. Subir imágenes web a Google Drive
      List<String> webImageUrls = [];
      if (_webImages.isNotEmpty) {
        setState(
          () => _uploadStatus = 'Subiendo imágenes web a Google Drive...',
        );
        webImageUrls = await GoogleDriveUploadService.uploadMultipleImages(
          projectId: projectId,
          type: 'web',
          files: _webImages,
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = (current / total) * 0.4;
              _uploadStatus = 'Subiendo imagen web $current de $total';
            });
          },
        );
      }

      // 2. Subir imágenes mobile a Google Drive
      List<String> mobileImageUrls = [];
      if (_mobileImages.isNotEmpty) {
        setState(
          () => _uploadStatus = 'Subiendo imágenes mobile a Google Drive...',
        );
        mobileImageUrls = await GoogleDriveUploadService.uploadMultipleImages(
          projectId: projectId,
          type: 'mobile',
          files: _mobileImages,
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = 0.4 + (current / total) * 0.3;
              _uploadStatus = 'Subiendo imagen mobile $current de $total';
            });
          },
        );
      }

      // 3. Subir logo a Google Drive
      String? logoUrl;
      if (_logo != null) {
        setState(() => _uploadStatus = 'Subiendo logo a Google Drive...');
        final logoUrls = await GoogleDriveUploadService.uploadMultipleImages(
          projectId: projectId,
          type: 'logo',
          files: [_logo!],
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = 0.7;
              _uploadStatus = 'Subiendo logo...';
            });
          },
        );
        logoUrl = logoUrls.isNotEmpty ? logoUrls.first : null;
      }

      // 4. Guardar URLs en Firebase Realtime Database
      setState(() {
        _uploadProgress = 0.8;
        _uploadStatus = 'Guardando proyecto en base de datos...';
      });

      await FirebaseService.saveProject(
        id: projectId, // Usar el mismo ID generado
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        link: _linkController.text.trim(),
        images: webImageUrls,
        imagesMobile: mobileImageUrls,
        logo: logoUrl,
      );

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = '¡Proyecto guardado exitosamente!';
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Proyecto creado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Esperar un momento y regresar
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/project');
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
            '❌ Se cerró la ventana de Google.\n\nPor favor, autoriza el acceso a Google Drive para poder subir las imágenes.';
      } else if (errorStr.contains('AUTENTICACION_CANCELADA')) {
        errorMessage =
            '❌ Autenticación cancelada.\n\nNecesitas autorizar el acceso a Google Drive para subir imágenes.';
      } else if (errorStr.contains('NetworkError') ||
          errorStr.contains('network')) {
        errorMessage =
            '❌ Error de conexión.\n\nVerifica tu conexión a internet e intenta nuevamente.';
      } else {
        errorMessage = 'Error al guardar proyecto: $e';
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
                'Debes iniciar sesión para subir proyectos',
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
      title: const Text('Subir Proyecto'),
      backgroundColor: const Color(0xFF0d0d0d),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isUploading ? null : () => context.go('/project'),
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
                  '📝 Información del Proyecto',
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
                    label: 'Nombre del Proyecto',
                    hint: 'Ej: COMPAÑIA DE TAXIS, CABBIE',
                    icon: Icons.title,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                const SizedBox(height: 20),

                // Campo: Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    label: 'Descripción',
                    hint: 'Describe el proyecto en detalle...',
                    icon: Icons.description,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                  maxLines: 6,
                  maxLength: 1000,
                ),
                const SizedBox(height: 20),

                // Campo: Link
                TextFormField(
                  controller: _linkController,
                  decoration: _inputDecoration(
                    label: 'Link del Proyecto',
                    hint: 'https://ejemplo.com',
                    icon: Icons.link,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El link es requerido';
                    }
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return 'El link debe comenzar con http:// o https://';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 40),

                // Sección de Logo
                _buildLogoSection(),
                const SizedBox(height: 40),

                // Sección de imágenes WEB
                const Text(
                  '🖥️ Imágenes Web',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 10),
                _buildImageSection(
                  images: _webImages,
                  onPickImages: _pickWebImages,
                  onRemoveImage: _removeWebImage,
                  emptyMessage: 'No hay imágenes web',
                ),
                const SizedBox(height: 40),

                // Sección de imágenes MOBILE
                const Text(
                  '📱 Imágenes Mobile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
                const SizedBox(height: 10),
                _buildImageSection(
                  images: _mobileImages,
                  onPickImages: _pickMobileImages,
                  onRemoveImage: _removeMobileImage,
                  emptyMessage: 'No hay imágenes mobile',
                ),
                const SizedBox(height: 40),

                // Botón guardar
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveProject,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'GUARDAR PROYECTO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d0d0d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón cancelar
                OutlinedButton(
                  onPressed: _isUploading ? null : () => context.go('/project'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('CANCELAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final authController = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle, size: 40, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Autenticado como:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  authController.userEmail ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection({
    required List<PlatformFile> images,
    required VoidCallback onPickImages,
    required Function(int) onRemoveImage,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón para agregar imágenes
        OutlinedButton.icon(
          onPressed: onPickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Agregar Imágenes'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Vista previa de imágenes
        if (images.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildImagePreview(file, index, onRemoveImage);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildImagePreview(
    PlatformFile file,
    int index,
    Function(int) onRemove,
  ) {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb && file.bytes != null
                ? Image.memory(file.bytes!, fit: BoxFit.cover)
                : file.path != null
                ? Image.file(File(file.path!), fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),
        ),
        // Botón eliminar
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.red,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => onRemove(index),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏢 Logo del Proyecto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0d0d0d),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Imagen representativa del proyecto',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón para agregar
          OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.add_photo_alternate, color: Colors.orange),
            label: const Text(
              'Agregar Logo',
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.orange, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Preview
          if (_logo == null)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay logo aún',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb && _logo!.bytes != null
                          ? Image.memory(_logo!.bytes!, fit: BoxFit.contain)
                          : _logo!.path != null
                          ? Image.file(File(_logo!.path!), fit: BoxFit.contain)
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  // Botón eliminar
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.red,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _removeLogo,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Badge "NUEVO"
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LOGO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
