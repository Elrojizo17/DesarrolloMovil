import 'package:supabase_flutter/supabase_flutter.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final int stock;
  final String? imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    this.imagenUrl,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] ?? '',
      nombre: map['nombre'],
      precio: (map['precio'] as num).toDouble(),
      stock: map['stock'],
      imagenUrl: map['imagen_url'],
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'precio': precio,
    'stock': stock,
    'imagen_url': imagenUrl,
    'user_id': Supabase.instance.client.auth.currentUser!.id,
  };

  Map<String, dynamic> toMapConId() => {
    ...toMap(),
    'id': id,
  };
}