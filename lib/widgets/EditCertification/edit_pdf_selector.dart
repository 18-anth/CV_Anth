import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EditPdfSelector extends StatelessWidget {
  final PlatformFile? pdfFile;
  final String? currentPdfUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EditPdfSelector({
    super.key,
    required this.pdfFile,
    required this.currentPdfUrl,
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
    final hasCurrentPdf = currentPdfUrl != null && currentPdfUrl!.isNotEmpty;
    final hasNewPdf = pdfFile != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text(
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
                          pdfFile!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFileSize(pdfFile!.size),
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
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón para seleccionar/cambiar PDF
          OutlinedButton.icon(
            onPressed: onPick,
            icon: Icon(hasNewPdf ? Icons.refresh : Icons.upload_file),
            label: Text(
              hasNewPdf
                  ? 'Cambiar PDF'
                  : (hasCurrentPdf ? 'Subir nuevo PDF' : 'Seleccionar PDF'),
            ),
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
}
