import 'package:flutter/material.dart';

/// Widget reutilizável para paginação de dados.
class PaginationWidget extends StatefulWidget {
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;

  const PaginationWidget({
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    super.key,
  });

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  int _currentPage = 1;

  int get _totalPages => (widget.totalItems / widget.itemsPerPage).ceil();

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
      widget.onPageChanged(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_totalPages <= 1) {
      return const SizedBox.shrink(); // Não mostra paginação se há apenas 1 página
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Primeira página',
          ),
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),
          ...List.generate(
            _totalPages > 5
                ? 5
                : _totalPages, // Mostra até 5 botões
            (index) {
              int pageNumber;
              if (_totalPages <= 5) {
                pageNumber = index + 1;
              } else {
                // Lógica para mostrar páginas ao redor da página atual
                if (_currentPage <= 3) {
                  pageNumber = index + 1;
                } else if (_currentPage >= _totalPages - 2) {
                  pageNumber = _totalPages - 4 + index;
                } else {
                  pageNumber = _currentPage - 2 + index;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: () => _goToPage(pageNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == pageNumber
                        ? Colors.deepPurple
                        : Colors.grey[300],
                    foregroundColor: _currentPage == pageNumber
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text(pageNumber.toString()),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
          ),
          IconButton(
            onPressed: _currentPage < _totalPages ? () => _goToPage(_totalPages) : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Última página',
          ),
          const SizedBox(width: 16),
          Text(
            'Página $_currentPage de $_totalPages',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
