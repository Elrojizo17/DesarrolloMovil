import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class FormularioProducto extends StatefulWidget {
  final VoidCallback onGuardado;
  final Producto? producto; // null = crear, objeto = editar

  const FormularioProducto({
    super.key,
    required this.onGuardado,
    this.producto,
  });

  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController();
  File? _imagen;
  bool _guardando = false;
  final _service = ProductoService();

  @override
  void initState() {
    super.initState();
    // Precarga datos si es edición
    if (widget.producto != null) {
      _nombre.text = widget.producto!.nombre;
      _precio.text = widget.producto!.precio.toString();
      _stock.text = widget.producto!.stock.toString();
    }
  }

  Future<void> _seleccionarImagen() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imagen = File(picked.path));
  }

  Future<void> _guardar() async {
    if (_nombre.text.isEmpty || _precio.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son obligatorios')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      String? imagenUrl = widget.producto?.imagenUrl;
      if (_imagen != null) {
        imagenUrl = await _service.subirImagen(_imagen!);
      }

      final producto = Producto(
        id: widget.producto?.id ?? '',
        nombre: _nombre.text.trim(),
        precio: double.parse(_precio.text),
        stock: int.tryParse(_stock.text) ?? 0,
        imagenUrl: imagenUrl,
      );

      if (widget.producto != null) {
        await _service.actualizar(producto);
      } else {
        await _service.crear(producto);
      }

      widget.onGuardado();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.producto != null ? 'Editar producto' : 'Nuevo producto',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Imagen
          GestureDetector(
            onTap: _seleccionarImagen,
            child: Container(
              height: 120, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imagen != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imagen!, fit: BoxFit.cover),
                    )
                  : widget.producto?.imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.producto!.imagenUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 36, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Toca para agregar imagen',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _precio,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.producto != null
                      ? 'Guardar cambios'
                      : 'Agregar producto'),
            ),
          ),
        ],
      ),
    );
  }
}