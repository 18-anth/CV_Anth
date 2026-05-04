import 'package:flutter/material.dart';

class UploadProjectTechnologiesSection extends StatelessWidget {
  final Map<String, List<String>> technologiesMap;
  final List<String> selectedTechnologies;
  final Function(String) onRemoveTechnology;
  final VoidCallback onShowDialog;

  const UploadProjectTechnologiesSection({
    super.key,
    required this.technologiesMap,
    required this.selectedTechnologies,
    required this.onRemoveTechnology,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
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
          if (selectedTechnologies.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedTechnologies.map((tech) {
                return Chip(
                  label: Text(tech),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onRemoveTechnology(tech),
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
            onPressed: onShowDialog,
            icon: const Icon(Icons.add),
            label: Text(
              selectedTechnologies.isEmpty
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

          if (selectedTechnologies.isEmpty)
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
}

// ══════════════════════════════════════════════════════════════════
// DIÁLOGO DE TECNOLOGÍAS
// ══════════════════════════════════════════════════════════════════

class TechnologiesDialog extends StatefulWidget {
  final Map<String, List<String>> technologiesMap;
  final List<String> selectedTechnologies;
  final Function(List<String>) onTechnologiesSelected;

  const TechnologiesDialog({
    super.key,
    required this.technologiesMap,
    required this.selectedTechnologies,
    required this.onTechnologiesSelected,
  });

  @override
  State<TechnologiesDialog> createState() => _TechnologiesDialogState();
}

class _TechnologiesDialogState extends State<TechnologiesDialog> {
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
              onChanged: (value) => setState(() => _searchQuery = value),
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
