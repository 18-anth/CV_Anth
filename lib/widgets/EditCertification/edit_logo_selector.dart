import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EditLogoSelector extends StatelessWidget {
  final String title;
  final String subtitle;
  final PlatformFile? file;
  final String? currentUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EditLogoSelector({
    super.key,
    required this.title,
    required this.subtitle,
    required this.file,
    required this.currentUrl,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasCurrentLogo = currentUrl != null && currentUrl!.isNotEmpty;
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
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
                      currentUrl!,
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
                    child: file!.bytes != null
                        ? Image.memory(
                            file!.bytes!,
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
              'Nuevo logo: ${file!.name}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
          ],

          // Botón para seleccionar/cambiar logo
          OutlinedButton.icon(
            onPressed: onPick,
            icon: Icon(hasNewLogo ? Icons.refresh : Icons.upload),
            label: Text(
              hasNewLogo
                  ? 'Cambiar Logo'
                  : (hasCurrentLogo ? 'Subir nuevo logo' : 'Seleccionar Logo'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0d0d0d),
              side: const BorderSide(color: Color(0xFF0d0d0d)),
            ),
          ),
        ],
      ),
    );
  }
}
