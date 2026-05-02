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

class EditProject extends StatefulWidget {
  final String projectId;

  const EditProject({super.key, required this.projectId});

  @override
  State<EditProject> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _problemSolvedController = TextEditingController();
  final _difficultiesController = TextEditingController();
  final _testimonialsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  String? _selectedClassification;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedTechnologies = [];

  // Imágenes nuevas que se van a subir
  final List<PlatformFile> _newWebImages = [];
  final List<PlatformFile> _newMobileImages = [];

  // URLs de imágenes existentes
  final List<String> _existingWebImages = [];
  final List<String> _existingMobileImages = [];

  // Logo
  String? _existingLogo;
  PlatformFile? _newLogo;

  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  bool _isLoadingTechnologies = true;
  Map<String, List<String>> _technologiesMap = {};

  final List<String> _classifications = [
    'Prácticas profesionales',
    'Freelancer',
    'Proyectos de universidad',
  ];

  @override
  void initState() {
    super.initState();
    _loadTechnologies();
    _loadProjectData();
  }

  Future<void> _loadTechnologies() async {
    try {
      final technologies = await FirebaseService.fetchTechnologies();
      if (!mounted) return;
      setState(() {
        _technologiesMap = technologies;
        _isLoadingTechnologies = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTechnologies = false;
      });
      _showError('Error al cargar tecnologías: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _problemSolvedController.dispose();
    _difficultiesController.dispose();
    _testimonialsController.dispose();
    _responsibilitiesController.dispose();
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
        _titleController.text = projectData['title'] ?? '';
        _nameController.text = projectData['name'] ?? '';
        _descriptionController.text = projectData['description'] ?? '';
        _linkController.text = projectData['link'] ?? '';
        _problemSolvedController.text = projectData['problemSolved'] ?? '';
        _difficultiesController.text = projectData['difficulties'] ?? '';
        _testimonialsController.text = projectData['testimonials'] ?? '';
        _responsibilitiesController.text =
            projectData['responsibilities'] ?? '';
        _selectedClassification = projectData['classification'] as String?;

        // Cargar fechas
        if (projectData['startDate'] != null) {
          try {
            _startDate = DateTime.parse(projectData['startDate']);
          } catch (e) {
            // Ignorar error de parseo
          }
        }
        if (projectData['endDate'] != null) {
          try {
            _endDate = DateTime.parse(projectData['endDate']);
          } catch (e) {
            // Ignorar error de parseo
          }
        }

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

        // Cargar logo
        _existingLogo = projectData['logo'] as String?;

        // Cargar tecnologías
        if (projectData['technologies'] is List) {
          _selectedTechnologies = List<String>.from(
            (projectData['technologies'] as List).map((e) => e.toString()),
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

  Future<void> _pickNewLogo() async {
    try {
      // Usar FilePicker (funciona en todas las plataformas incluido web)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _newLogo = result.files.first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar logo: $e');
    }
  }

  void _removeExistingLogo() {
    setState(() {
      _existingLogo = null;
    });
  }

  void _removeNewLogo() {
    setState(() {
      _newLogo = null;
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
      _uploadStatus = 'Conectando con Google Drive...';
    });

    try {
      // 0. Mostrar instrucciones antes de autenticar si hay nuevas imágenes
      if (_newWebImages.isNotEmpty ||
          _newMobileImages.isNotEmpty ||
          _newLogo != null) {
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
      }

      // 1. Subir nuevas imágenes web a Google Drive
      List<String> newWebImageUrls = [];
      if (_newWebImages.isNotEmpty) {
        setState(
          () =>
              _uploadStatus = 'Subiendo nuevas imágenes web a Google Drive...',
        );
        newWebImageUrls = await GoogleDriveUploadService.uploadMultipleImages(
          projectId: widget.projectId,
          type: 'web',
          files: _newWebImages,
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = (current / total) * 0.3;
              _uploadStatus = 'Subiendo imagen web $current de $total';
            });
          },
        );
      }

      // 2. Subir nuevas imágenes mobile a Google Drive
      List<String> newMobileImageUrls = [];
      if (_newMobileImages.isNotEmpty) {
        setState(
          () => _uploadStatus =
              'Subiendo nuevas imágenes mobile a Google Drive...',
        );
        newMobileImageUrls =
            await GoogleDriveUploadService.uploadMultipleImages(
              projectId: widget.projectId,
              type: 'mobile',
              files: _newMobileImages,
              onProgress: (current, total) {
                setState(() {
                  _uploadProgress = 0.3 + (current / total) * 0.3;
                  _uploadStatus = 'Subiendo imagen mobile $current de $total';
                });
              },
            );
      }

      // 3. Subir logo a Google Drive si hay uno nuevo
      String? logoUrl = _existingLogo;
      if (_newLogo != null) {
        setState(() => _uploadStatus = 'Subiendo logo a Google Drive...');
        final logoUrls = await GoogleDriveUploadService.uploadMultipleImages(
          projectId: widget.projectId,
          type: 'logo',
          files: [_newLogo!],
          onProgress: (current, total) {
            setState(() {
              _uploadProgress = 0.6;
              _uploadStatus = 'Subiendo logo...';
            });
          },
        );
        logoUrl = logoUrls.isNotEmpty ? logoUrls.first : null;
      }

      // 4. Combinar imágenes existentes con las nuevas
      final allWebImages = [..._existingWebImages, ...newWebImageUrls];
      final allMobileImages = [..._existingMobileImages, ...newMobileImageUrls];

      // 5. Actualizar URLs en Firebase Realtime Database
      setState(() {
        _uploadProgress = 0.7;
        _uploadStatus = 'Actualizando proyecto en base de datos...';
      });

      await FirebaseService.saveProject(
        id: widget.projectId, // Usar el ID existente para actualizar
        title: _titleController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        link: _linkController.text.trim(),
        classification: _selectedClassification,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        images: allWebImages,
        imagesMobile: allMobileImages,
        logo: logoUrl,
        technologies: _selectedTechnologies,
        problemSolved: _problemSolvedController.text.trim(),
        difficulties: _difficultiesController.text.trim(),
        testimonials: _testimonialsController.text.trim(),
        responsibilities: _responsibilitiesController.text.trim(),
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
        errorMessage = 'Error al actualizar proyecto: $e';
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

    if (_isLoadingTechnologies) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Cargando tecnologías...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                  controller: _titleController,
                  label: 'Título',
                  icon: Icons.star,
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                // Clasificación
                DropdownButtonFormField<String>(
                  value: _selectedClassification,
                  decoration: InputDecoration(
                    labelText: 'Clasificación',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _classifications.map((classification) {
                    return DropdownMenuItem<String>(
                      value: classification,
                      child: Text(classification),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassification = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La clasificación es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Fecha de inicio
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Inicio',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _startDate == null
                          ? 'Selecciona la fecha de inicio'
                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      style: TextStyle(
                        color: _startDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Fecha de culminación
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2000),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 10),
                      ),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Culminación',
                      prefixIcon: const Icon(Icons.event_available),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _endDate == null
                          ? 'Selecciona la fecha de culminación'
                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      style: TextStyle(
                        color: _endDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
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
                  controller: _problemSolvedController,
                  label: 'Problema que resuelve',
                  icon: Icons.lightbulb_outline,
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _difficultiesController,
                  label: 'Dificultades y soluciones',
                  icon: Icons.engineering,
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _testimonialsController,
                  label: 'Testimonios o feedback',
                  icon: Icons.rate_review,
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _responsibilitiesController,
                  label: 'Responsabilidades',
                  icon: Icons.assignment_ind,
                  maxLines: 4,
                  maxLength: 500,
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
                const SizedBox(height: 32),
                _buildTechnologiesSection(),
                const SizedBox(height: 32),
                _buildLogoSection(),
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
          controller: _titleController,
          label: 'Título',
          icon: Icons.star,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
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
        // Clasificación
        DropdownButtonFormField<String>(
          value: _selectedClassification,
          decoration: InputDecoration(
            labelText: 'Clasificación',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _classifications.map((classification) {
            return DropdownMenuItem<String>(
              value: classification,
              child: Text(classification),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClassification = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La clasificación es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Fecha de inicio
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha de Inicio',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _startDate == null
                  ? 'Selecciona la fecha de inicio'
                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              style: TextStyle(
                color: _startDate == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Fecha de culminación
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now(),
              firstDate: _startDate ?? DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (date != null) {
              setState(() {
                _endDate = date;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha de Culminación',
              prefixIcon: const Icon(Icons.event_available),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _endDate == null
                  ? 'Selecciona la fecha de culminación'
                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
              style: TextStyle(
                color: _endDate == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
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
          controller: _problemSolvedController,
          label: 'Problema que resuelve',
          icon: Icons.lightbulb_outline,
          maxLines: 4,
          maxLength: 500,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _difficultiesController,
          label: 'Dificultades y soluciones',
          icon: Icons.engineering,
          maxLines: 4,
          maxLength: 500,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _testimonialsController,
          label: 'Testimonios o feedback',
          icon: Icons.rate_review,
          maxLines: 4,
          maxLength: 500,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _responsibilitiesController,
          label: 'Responsabilidades',
          icon: Icons.assignment_ind,
          maxLines: 4,
          maxLength: 500,
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
        _buildTechnologiesSection(),
        const SizedBox(height: 32),
        _buildLogoSection(),
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
  Widget _buildLogoSection() {
    final hasLogo = _existingLogo != null || _newLogo != null;
    final isNewLogo = _newLogo != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!),
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logo del Proyecto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Imagen representativa del proyecto',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botón para agregar/cambiar
          OutlinedButton.icon(
            onPressed: _pickNewLogo,
            icon: Icon(
              hasLogo ? Icons.change_circle : Icons.add_photo_alternate,
              color: Colors.orange,
            ),
            label: Text(
              hasLogo ? 'Cambiar Logo' : 'Agregar Logo',
              style: const TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview del logo
          if (hasLogo)
            Center(
              child: isNewLogo
                  ? _buildNewLogoPreview()
                  : _buildExistingLogoPreview(),
            ),

          // Mensaje si no hay logo
          if (!hasLogo)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    'No hay logo aún',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExistingLogoPreview() {
    return Stack(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(_existingLogo!),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeExistingLogo,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewLogoPreview() {
    return Stack(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? Image.memory(_newLogo!.bytes!, fit: BoxFit.contain)
                : Image.file(File(_newLogo!.path!), fit: BoxFit.contain),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeNewLogo,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'NUEVO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

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

  // ══════════════════════════════════════════════════════════════
  // SECCIÓN DE TECNOLOGÍAS
  // ══════════════════════════════════════════════════════════════

  Widget _buildTechnologiesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.blue[700], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '💻 Tecnologías Utilizadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d0d0d),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona las tecnologías, lenguajes, metodologías y herramientas utilizadas en este proyecto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Mostrar tecnologías seleccionadas
          if (_selectedTechnologies.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTechnologies.map((tech) {
                return Chip(
                  label: Text(tech),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _selectedTechnologies.remove(tech);
                    });
                  },
                  backgroundColor: Colors.blue[100],
                  labelStyle: const TextStyle(
                    color: Color(0xFF0d0d0d),
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Botón para agregar tecnologías
          ElevatedButton.icon(
            onPressed: _showTechnologiesDialog,
            icon: const Icon(Icons.add),
            label: Text(
              _selectedTechnologies.isEmpty
                  ? 'Agregar Tecnologías'
                  : 'Agregar Más Tecnologías',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          if (_selectedTechnologies.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '⚠️ Agregar tecnologías ayudará a destacar las habilidades del proyecto',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTechnologiesDialog() {
    showDialog(
      context: context,
      builder: (context) => _TechnologiesDialog(
        technologiesMap: _technologiesMap,
        selectedTechnologies: _selectedTechnologies,
        onTechnologiesSelected: (selected) {
          setState(() {
            _selectedTechnologies = selected;
          });
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DIÁLOGO DE SELECCIÓN DE TECNOLOGÍAS
// ══════════════════════════════════════════════════════════════

class _TechnologiesDialog extends StatefulWidget {
  final Map<String, List<String>> technologiesMap;
  final List<String> selectedTechnologies;
  final Function(List<String>) onTechnologiesSelected;

  const _TechnologiesDialog({
    required this.technologiesMap,
    required this.selectedTechnologies,
    required this.onTechnologiesSelected,
  });

  @override
  State<_TechnologiesDialog> createState() => _TechnologiesDialogState();
}

class _TechnologiesDialogState extends State<_TechnologiesDialog> {
  late List<String> _tempSelected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedTechnologies);
  }

  List<String> _getFilteredTechnologies() {
    if (_searchQuery.isEmpty) return [];

    final allTechs = <String>[];
    widget.technologiesMap.forEach((category, techs) {
      allTechs.addAll(techs);
    });

    return allTechs
        .where(
          (tech) => tech.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTechs = _getFilteredTechnologies();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.settings, color: Color(0xFF0d0d0d), size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Seleccionar Tecnologías',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0d0d0d),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_tempSelected.length} tecnologías seleccionadas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tecnología...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Resultados de búsqueda o categorías
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults(filteredTechs)
                  : _buildCategorizedTechnologies(),
            ),

            // Botones de acción
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTechnologiesSelected(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0d0d0d),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Selección',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<String> filteredTechs) {
    if (filteredTechs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron tecnologías',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredTechs.map((tech) {
            final isSelected = _tempSelected.contains(tech);
            return FilterChip(
              label: Text(tech),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tempSelected.add(tech);
                  } else {
                    _tempSelected.remove(tech);
                  }
                });
              },
              selectedColor: Colors.blue[200],
              checkmarkColor: const Color(0xFF0d0d0d),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorizedTechnologies() {
    return ListView(
      children: widget.technologiesMap.entries.map((entry) {
        final category = entry.key;
        final technologies = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0d0d0d),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: technologies.map((tech) {
                final isSelected = _tempSelected.contains(tech);
                return FilterChip(
                  label: Text(tech),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tempSelected.add(tech);
                      } else {
                        _tempSelected.remove(tech);
                      }
                    });
                  },
                  selectedColor: Colors.blue[200],
                  checkmarkColor: const Color(0xFF0d0d0d),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}
