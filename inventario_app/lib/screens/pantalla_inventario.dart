import 'dart:async';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/auth_service.dart';
import '../services/producto_service.dart';
import '../widgets/formulario_producto.dart';
import '../widgets/panel_filtros.dart';

class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});
  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _service = ProductoService();
  final _auth = AuthService();
  final _busqueda = TextEditingController();
  List<Producto> _productos = [];
  bool _cargando = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    _productos = await _service.listar();
    setState(() => _cargando = false);
  }

  void _onBusquedaChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        _cargarProductos();
      } else {
        _buscarProductos(query);
      }
    });
  }

  Future<void> _buscarProductos(String query) async {
    setState(() => _cargando = true);
    _productos = await _service.buscar(query);
    setState(() => _cargando = false);
  }

  Future<void> _eliminar(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Estás seguro de que quieres eliminarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.eliminar(id);
      _cargarProductos();
    }
  }

  void _abrirFormulario({Producto? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FormularioProducto(
        producto: producto,
        onGuardado: () {
          Navigator.pop(context);
          _cargarProductos();
        },
      ),
    );
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PanelFiltros(
        onFiltrar: (min, max) async {
          Navigator.pop(context);
          setState(() => _cargando = true);
          _productos = await _service.filtrarPorStock(min, max);
          setState(() => _cargando = false);
        },
        onLimpiar: () {
          Navigator.pop(context);
          _busqueda.clear();
          _cargarProductos();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Inventario'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _abrirFiltros,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _auth.logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _busqueda,
              onChanged: _onBusquedaChanged,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busqueda.clear();
                          _cargarProductos();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),

          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _productos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Sin productos',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarProductos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _productos.length,
                          itemBuilder: (_, i) {
                            final p = _productos[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: p.imagenUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          p.imagenUrl!,
                                          width: 56, height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      )
                                    : Container(
                                        width: 56, height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.inventory_2,
                                            color: Colors.indigo),
                                      ),
                                title: Text(p.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Row(
                                  children: [
                                    Text('\$${p.precio.toStringAsFixed(2)}'),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: p.stock > 5
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Stock: ${p.stock}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: p.stock > 5
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.indigo),
                                      onPressed: () =>
                                          _abrirFormulario(producto: p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _eliminar(p.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

