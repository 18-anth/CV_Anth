import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../services/firebase_storage_service.dart';
import '../../utils/Colors.dart';

class EditProject extends StatefulWidget {
  final String projectId;

  const EditProject({super.key, required this.projectId});

  @override
  State<EditProject> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  // Imágenes nuevas que se van a subir
  final List<PlatformFile> _newWebImages = [];
  final List<PlatformFile> _newMobileImages = [];

  // URLs de imágenes existentes
  final List<String> _existingWebImages = [];
  final List<String> _existingMobileImages = [];

  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // CARGAR DATOS DEL PROYECTO
  // ══════════════════════════════════════════════════════════════

  Future<void> _loadProjectData() async {
    try {
      final projectData = await FirebaseService.fetchProjectById(
        widget.projectId,
      );

      if (projectData == null) {
        if (!mounted) return;
        _showError('Proyecto no encontrado');
        context.go('/project');
        return;
      }

      setState(() {
        _nameController.text = projectData['name'] ?? '';
        _descriptionController.text = projectData['description'] ?? '';
        _linkController.text = projectData['link'] ?? '';

        // Cargar imágenes existentes
        if (projectData['images'] is List) {
          _existingWebImages.addAll(
            (projectData['images'] as List).map((e) => e.toString()),
          );
        }
        if (projectData['imagesMobile'] is List) {
          _existingMobileImages.addAll(
            (projectData['imagesMobile'] as List).map((e) => e.toString()),
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Error al cargar proyecto: $e');
      context.go('/project');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODOS PARA SELECCIONAR Y ELIMINAR IMÁGENES
  // ══════════════════════════════════════════════════════════════

  Future<void> _pickNewWebImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _newWebImages.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imágenes web: $e');
    }
  }

  Future<void> _pickNewMobileImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _newMobileImages.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imágenes mobile: $e');
    }
  }

  void _removeExistingWebImage(int index) {
    setState(() {
      _existingWebImages.removeAt(index);
    });
  }

  void _removeExistingMobileImage(int index) {
    setState(() {
      _existingMobileImages.removeAt(index);
    });
  }

  void _removeNewWebImage(int index) {
    setState(() {
      _newWebImages.removeAt(index);
    });
  }

  void _removeNewMobileImage(int index) {
    setState(() {
      _newMobileImages.removeAt(index);
    });
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTODO PARA ACTUALIZAR EL PROYECTO
  // ══════════════════════════════════════════════════════════════

  Future<void> _updateProject() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya al menos una imagen (existente o nueva)
    if (_existingWebImages.isEmpty &&
        _existingMobileImages.isEmpty &&
        _newWebImages.isEmpty &&
        _newMobileImages.isEmpty) {
      _showError('Debes tener al menos una imagen (web o mobile)');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparando...';
    });

    try {
      // 1. Subir nuevas imágenes web
      List<String> newWebImageUrls = [];
      if (_newWebImages.isNotEmpty) {
        setState(() => _uploadStatus = 'Subiendo nuevas imágenes web...');
        newWebImageUrls = await FirebaseStorageService.uploadMultipleImages(
          images: _newWebImages,
          folder: 'Project/Web',
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = (current / total) * 0.3;
              _uploadStatus = 'Subiendo imagen web $current de $total';
            });
          },
        );
      }

      // 2. Subir nuevas imágenes mobile
      List<String> newMobileImageUrls = [];
      if (_newMobileImages.isNotEmpty) {
        setState(() => _uploadStatus = 'Subiendo nuevas imágenes mobile...');
        newMobileImageUrls = await FirebaseStorageService.uploadMultipleImages(
          images: _newMobileImages,
          folder: 'Project/Mobile',
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = 0.3 + (current / total) * 0.3;
              _uploadStatus = 'Subiendo imagen mobile $current de $total';
            });
          },
        );
      }

      // 3. Combinar imágenes existentes con las nuevas
      final allWebImages = [..._existingWebImages, ...newWebImageUrls];
      final allMobileImages = [..._existingMobileImages, ...newMobileImageUrls];

      // 4. Actualizar en Firebase Database
      setState(() {
        _uploadProgress = 0.7;
        _uploadStatus = 'Actualizando proyecto...';
      });

      await FirebaseService.saveProject(
        id: widget.projectId, // Usar el ID existente para actualizar
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        link: _linkController.text.trim(),
        images: allWebImages,
        imagesMobile: allMobileImages,
      );

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = '¡Proyecto actualizado exitosamente!';
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Proyecto actualizado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Esperar un momento y regresar al detalle
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/project/${widget.projectId}');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showError('Error al actualizar proyecto: $e');
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
                'Debes iniciar sesión para editar proyectos',
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
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
      title: const Text(
        'Editar Proyecto',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/project/${widget.projectId}'),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1024;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWideScreen ? 1400 : 800),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  Text(
                    'Edita la información de tu proyecto',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modifica los campos que desees actualizar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Contenido adaptativo (1 o 2 columnas)
                  isWideScreen
                      ? _buildTwoColumnLayout()
                      : _buildSingleColumnLayout(),

                  const SizedBox(height: 40),

                  // Botón Guardar
                  ElevatedButton.icon(
                    onPressed: _updateProject,
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text(
                      'ACTUALIZAR PROYECTO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LAYOUTS RESPONSIVOS
  // ══════════════════════════════════════════════════════════════

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: Campos de texto
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre del Proyecto',
                  icon: Icons.title,
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  icon: Icons.description,
                  maxLines: 5,
                  maxLength: 1000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _linkController,
                  label: 'Link del Proyecto',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
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
                ),
              ],
            ),
          ),
        ),

        // Columna derecha: Secciones de imágenes
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(
                  title: 'Imágenes Web',
                  subtitle: 'Imágenes para versión de escritorio',
                  existingImages: _existingWebImages,
                  newImages: _newWebImages,
                  onAddImages: _pickNewWebImages,
                  onRemoveExisting: _removeExistingWebImage,
                  onRemoveNew: _removeNewWebImage,
                  icon: Icons.computer,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                _buildImageSection(
                  title: 'Imágenes Mobile',
                  subtitle: 'Imágenes para versión móvil',
                  existingImages: _existingMobileImages,
                  newImages: _newMobileImages,
                  onAddImages: _pickNewMobileImages,
                  onRemoveExisting: _removeExistingMobileImage,
                  onRemoveNew: _removeNewMobileImage,
                  icon: Icons.phone_android,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre del Proyecto',
          icon: Icons.title,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _descriptionController,
          label: 'Descripción',
          icon: Icons.description,
          maxLines: 5,
          maxLength: 1000,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _linkController,
          label: 'Link del Proyecto',
          icon: Icons.link,
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El link es requerido';
            }
            if (!value.startsWith('http://') && !value.startsWith('https://')) {
              return 'El link debe comenzar con http:// o https://';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildImageSection(
          title: 'Imágenes Web',
          subtitle: 'Imágenes para versión de escritorio',
          existingImages: _existingWebImages,
          newImages: _newWebImages,
          onAddImages: _pickNewWebImages,
          onRemoveExisting: _removeExistingWebImage,
          onRemoveNew: _removeNewWebImage,
          icon: Icons.computer,
          color: Colors.blue,
        ),
        const SizedBox(height: 32),
        _buildImageSection(
          title: 'Imágenes Mobile',
          subtitle: 'Imágenes para versión móvil',
          existingImages: _existingMobileImages,
          newImages: _newMobileImages,
          onAddImages: _pickNewMobileImages,
          onRemoveExisting: _removeExistingMobileImage,
          onRemoveNew: _removeNewMobileImage,
          icon: Icons.phone_android,
          color: Colors.green,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // WIDGETS REUTILIZABLES
  // ══════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required String subtitle,
    required List<String> existingImages,
    required List<PlatformFile> newImages,
    required VoidCallback onAddImages,
    required Function(int) onRemoveExisting,
    required Function(int) onRemoveNew,
    required IconData icon,
    required Color color,
  }) {
    final totalImages = existingImages.length + newImages.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalImages ${totalImages == 1 ? "imagen" : "imágenes"}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botón para agregar
          OutlinedButton.icon(
            onPressed: onAddImages,
            icon: Icon(Icons.add_photo_alternate, color: color),
            label: Text('Agregar Imágenes', style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Grid de imágenes existentes
          if (existingImages.isNotEmpty) ...[
            Text(
              'Imágenes actuales (${existingImages.length}):',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: existingImages.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return _buildExistingImagePreview(
                  url,
                  () => onRemoveExisting(index),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Grid de imágenes nuevas
          if (newImages.isNotEmpty) ...[
            Text(
              'Imágenes nuevas (${newImages.length}):',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: newImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return _buildNewImagePreview(file, () => onRemoveNew(index));
              }).toList(),
            ),
          ],

          // Mensaje si no hay imágenes
          if (totalImages == 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No hay imágenes. Haz clic en "Agregar Imágenes"',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExistingImagePreview(String url, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagePreview(PlatformFile file, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? (file.bytes != null
                      ? Image.memory(file.bytes!, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40))
                : (file.path != null
                      ? Image.file(File(file.path!), fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40)),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        // Badge "NEW"
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'NUEVA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
            const SizedBox(height: 4),
            Text(
              _uploadStatus,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
