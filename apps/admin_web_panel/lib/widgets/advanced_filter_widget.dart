import 'package:flutter/material.dart';

/// Widget reutilizável para filtros avançados.
class AdvancedFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final List<String> filterOptions; // Ex: ['status', 'date_range', 'rating']

  const AdvancedFilterWidget({
    required this.onFilterChanged,
    required this.filterOptions,
    super.key,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  final Map<String, dynamic> _filters = {};
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  double _minRating = 0;
  double _maxRating = 5;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'search': _searchController.text,
      'status': _selectedStatus,
      'minRating': _minRating,
      'maxRating': _maxRating,
      'dateRange': _dateRange,
    };
    widget.onFilterChanged(filters);
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _minRating = 0;
      _maxRating = 5;
      _dateRange = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros Avançados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Search Filter
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                // Status Filter
                if (widget.filterOptions.contains('status'))
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        const DropdownMenuItem(
                          value: 'active',
                          child: Text('Ativo'),
                        ),
                        const DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inativo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                // Rating Filter
                if (widget.filterOptions.contains('rating'))
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avaliação: ${_minRating.toStringAsFixed(1)} - ${_maxRating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        RangeSlider(
                          min: 0,
                          max: 5,
                          divisions: 50,
                          values: RangeValues(_minRating, _maxRating),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _minRating = values.start;
                              _maxRating = values.end;
                            });
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                // Date Range Filter
                if (widget.filterOptions.contains('date_range'))
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Período'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final dateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (dateRange != null) {
                              setState(() {
                                _dateRange = dateRange;
                              });
                              _applyFilters();
                            }
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _dateRange != null
                                ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                                : 'Selecionar',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Limpar Filtros'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
