import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadPdfSelector extends StatelessWidget {
  final PlatformFile? pdfFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const UploadPdfSelector({
    super.key,
    required this.pdfFile,
    required this.onPick,
    required this.onRemove,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (pdfFile == null) ...[
            Icon(Icons.picture_as_pdf, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 15),
            const Text(
              'Selecciona un archivo PDF',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onPick,
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
                        pdfFile!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFileSize(pdfFile!.size),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: 'Eliminar PDF',
                ),
              ],
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: onPick,
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
}
