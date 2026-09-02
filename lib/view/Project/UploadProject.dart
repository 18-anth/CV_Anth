// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/upload_project_controller.dart';
import '../../utils/Colors.dart';
import '../../widgets/UploadProject/upload_project_uploading_widget.dart';
import '../../widgets/UploadProject/upload_project_user_info.dart';
import '../../widgets/UploadProject/upload_project_image_section.dart';
import '../../widgets/UploadProject/upload_project_logo_section.dart';
import '../../widgets/UploadProject/upload_project_technologies_section.dart';
import '../../widgets/UploadProject/upload_project_auth_dialog.dart';

class UploadProject extends StatefulWidget {
  const UploadProject({super.key});

  @override
  State<UploadProject> createState() => _UploadProjectState();
}

class _UploadProjectState extends State<UploadProject> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _problemSolvedController = TextEditingController();
  final _difficultiesController = TextEditingController();
  final _testimonialsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  late final UploadProjectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UploadProjectController();
    _controller.loadTechnologies().catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tecnologías: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
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
    _controller.dispose();
    super.dispose();
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

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_controller.webImages.isEmpty && _controller.mobileImages.isEmpty) {
      _showError('Debes agregar al menos una imagen (web o mobile)');
      return;
    }

    try {
      await _controller.saveProject(
        title: _titleController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        link: _linkController.text.trim(),
        problemSolved: _problemSolvedController.text.trim(),
        difficulties: _difficultiesController.text.trim(),
        testimonials: _testimonialsController.text.trim(),
        responsibilities: _responsibilitiesController.text.trim(),
        showAuthInstructions: () => UploadProjectAuthDialog.show(context),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Proyecto creado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/project');
    } catch (e) {
      _controller.resetUpload();

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

  void _showTechnologiesDialog() {
    showDialog(
      context: context,
      builder: (context) => TechnologiesDialog(
        technologiesMap: _controller.technologiesMap,
        selectedTechnologies: _controller.selectedTechnologies,
        onTechnologiesSelected: (selected) {
          _controller.setTechnologies(selected);
        },
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Subir Proyecto'),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0d0d0d),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _controller.isUploading
            ? null
            : () => context.go('/project'),
      ),
    );
  }

  Widget _buildForm(bool isMobile, UploadProjectController c) {
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
                UploadProjectUserInfo(
                  userEmail: context.watch<AuthController>().userEmail,
                ),
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

                // Campo: Título
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    label: 'Título',
                    hint: 'Ej: Desarrollador Full Stack',
                    icon: Icons.star,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                  maxLength: 100,
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

                // Campo: Clasificación
                DropdownButtonFormField<String>(
                  value: c.selectedClassification,
                  decoration: _inputDecoration(
                    label: 'Clasificación',
                    hint: 'Selecciona el tipo de proyecto',
                    icon: Icons.category,
                  ),
                  items: c.classifications.map((classification) {
                    return DropdownMenuItem<String>(
                      value: classification,
                      child: Text(classification),
                    );
                  }).toList(),
                  onChanged: (value) => c.setClassification(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La clasificación es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Fecha de inicio
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: c.startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) c.setStartDate(date);
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      label: 'Fecha de Inicio',
                      hint: 'Selecciona la fecha',
                      icon: Icons.calendar_today,
                    ),
                    child: Text(
                      c.startDate == null
                          ? 'Selecciona la fecha de inicio'
                          : '${c.startDate!.day}/${c.startDate!.month}/${c.startDate!.year}',
                      style: TextStyle(
                        color: c.startDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo: Fecha de culminación
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: c.endDate ?? DateTime.now(),
                      firstDate: c.startDate ?? DateTime(2000),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 10),
                      ),
                    );
                    if (date != null) c.setEndDate(date);
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      label: 'Fecha de Culminación',
                      hint: 'Selecciona la fecha',
                      icon: Icons.event_available,
                    ),
                    child: Text(
                      c.endDate == null
                          ? 'Selecciona la fecha de culminación'
                          : '${c.endDate!.day}/${c.endDate!.month}/${c.endDate!.year}',
                      style: TextStyle(
                        color: c.endDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
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

                // Campo: Problema que resuelve
                TextFormField(
                  controller: _problemSolvedController,
                  decoration: _inputDecoration(
                    label: 'Problema que resuelve',
                    hint: 'Describe la necesidad del cliente o usuario...',
                    icon: Icons.lightbulb_outline,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),

                // Campo: Dificultades y soluciones
                TextFormField(
                  controller: _difficultiesController,
                  decoration: _inputDecoration(
                    label: 'Dificultades y soluciones',
                    hint: 'Problemas técnicos importantes que resolviste...',
                    icon: Icons.engineering,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),

                // Campo: Testimonios o feedback
                TextFormField(
                  controller: _testimonialsController,
                  decoration: _inputDecoration(
                    label: 'Testimonios o feedback',
                    hint: 'Si trabajaste para clientes, su opinión...',
                    icon: Icons.rate_review,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),

                // Campo: Responsabilidades
                TextFormField(
                  controller: _responsibilitiesController,
                  decoration: _inputDecoration(
                    label: 'Responsabilidades',
                    hint: 'Qué hiciste exactamente dentro del proyecto...',
                    icon: Icons.assignment_ind,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 20),

                // Campo: Tecnologías
                UploadProjectTechnologiesSection(
                  technologiesMap: c.technologiesMap,
                  selectedTechnologies: c.selectedTechnologies,
                  onRemoveTechnology: c.removeTechnology,
                  onShowDialog: _showTechnologiesDialog,
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
                UploadProjectLogoSection(
                  logo: c.logo,
                  onPickLogo: c.pickLogo,
                  onRemoveLogo: c.removeLogo,
                ),
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
                UploadProjectImageSection(
                  images: c.webImages,
                  onPickImages: c.pickWebImages,
                  onRemoveImage: c.removeWebImage,
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
                UploadProjectImageSection(
                  images: c.mobileImages,
                  onPickImages: c.pickMobileImages,
                  onRemoveImage: c.removeMobileImage,
                  emptyMessage: 'No hay imágenes mobile',
                ),
                const SizedBox(height: 40),

                // Botón guardar
                ElevatedButton.icon(
                  onPressed: c.isUploading ? null : _saveProject,
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
                  onPressed: c.isUploading
                      ? null
                      : () => context.go('/project'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('CANCELAR'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Verificar carga de tecnologías
        if (_controller.isLoadingTechnologies) {
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
          body: _controller.isUploading
              ? UploadProjectUploadingWidget(
                  uploadStatus: _controller.uploadStatus,
                  uploadProgress: _controller.uploadProgress,
                )
              : _buildForm(isMobile, _controller),
        );
      },
    );
  }
}
