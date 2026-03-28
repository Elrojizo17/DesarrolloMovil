import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoService {
  final _db = Supabase.instance.client.from('productos');
  final _storage = Supabase.instance.client.storage.from('productos');

  // Listar todos
  Future<List<Producto>> listar() async {
    final data = await _db
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Producto.fromMap(e)).toList();
  }

  // Buscar por nombre
  Future<List<Producto>> buscar(String query) async {
    final data = await _db
        .select()
        .ilike('nombre', '%$query%')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Producto.fromMap(e)).toList();
  }

  // Filtrar por stock
  Future<List<Producto>> filtrarPorStock(int min, int max) async {
    final data = await _db
        .select()
        .gte('stock', min)
        .lte('stock', max)
        .order('nombre');
    return (data as List).map((e) => Producto.fromMap(e)).toList();
  }

  // Subir imagen
  Future<String?> subirImagen(File imagen) async {
    final nombre = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _storage.upload(nombre, imagen);
    return _storage.getPublicUrl(nombre);
  }

  // Crear
  Future<void> crear(Producto producto) async {
    await _db.insert(producto.toMap());
  }

  // Actualizar
  Future<void> actualizar(Producto producto) async {
    await _db
        .update(producto.toMap())
        .eq('id', producto.id);
  }

  // Eliminar
  Future<void> eliminar(String id) async {
    await _db.delete().eq('id', id);
  }
}