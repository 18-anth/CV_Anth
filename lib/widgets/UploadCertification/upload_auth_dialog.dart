import 'package:flutter/material.dart';

Future<bool> showUploadAuthInstructionsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
          SizedBox(width: 10),
          Text(
            'Autenticación requerida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Para subir archivos a Google Drive necesitas autenticarte. Sigue estos pasos:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            1,
            'Se abrirá una ventana del navegador',
            'Aparecerá la pantalla de Google para iniciar sesión',
          ),
          _buildInstructionStep(
            2,
            'Selecciona tu cuenta de Google',
            'Usa la cuenta con acceso a Google Drive',
          ),
          _buildInstructionStep(
            3,
            'Autoriza los permisos',
            'Permite acceso a Google Drive cuando se solicite',
          ),
          _buildInstructionStep(
            4,
            'Regresa a la aplicación',
            'La subida comenzará automáticamente',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Si cierras la ventana, la subida se cancelará',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(Icons.check),
          label: const Text('Entendido, continuar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0d0d0d),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Widget _buildInstructionStep(int step, String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF0d0d0d),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
