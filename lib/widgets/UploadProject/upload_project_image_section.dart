import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;

class UploadProjectImageSection extends StatelessWidget {
  final List<PlatformFile> images;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final String emptyMessage;

  const UploadProjectImageSection({
    super.key,
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
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
              return _buildImagePreview(file, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildImagePreview(PlatformFile file, int index) {
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
              onTap: () => onRemoveImage(index),
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
}
