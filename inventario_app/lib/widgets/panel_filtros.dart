import 'package:flutter/material.dart';

class PanelFiltros extends StatefulWidget {
  final Function(int min, int max) onFiltrar;
  final VoidCallback onLimpiar;

  const PanelFiltros({
    super.key,
    required this.onFiltrar,
    required this.onLimpiar,
  });

  @override
  State<PanelFiltros> createState() => _PanelFiltrosState();
}

class _PanelFiltrosState extends State<PanelFiltros> {
  RangeValues _rango = const RangeValues(0, 200);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('Filtrar por stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Stock: ${_rango.start.toInt()} – ${_rango.end.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          RangeSlider(
            values: _rango,
            min: 0, max: 200,
            divisions: 20,
            labels: RangeLabels(
              _rango.start.toInt().toString(),
              _rango.end.toInt().toString(),
            ),
            onChanged: (v) => setState(() => _rango = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onLimpiar,
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => widget.onFiltrar(
                    _rango.start.toInt(),
                    _rango.end.toInt(),
                  ),
                  child: const Text('Aplicar filtro'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}