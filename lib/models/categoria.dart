/// Respuesta de GET /api/categorias: categorías y subcategorías ACTIVAS,
/// anidadas. Es lo que pinta el formulario de nueva solicitud.
class Subcategoria {
  final int id;
  final String nombre;

  /// true si al elegir esta opción el usuario debe describir el detalle
  /// con texto libre (se envía como `detalleTexto`).
  final bool permiteTextoLibre;

  Subcategoria({
    required this.id,
    required this.nombre,
    required this.permiteTextoLibre,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: json['id'] as int,
      nombre: (json['nombre'] ?? '') as String,
      permiteTextoLibre: json['permiteTextoLibre'] == true,
    );
  }
}

class Categoria {
  final int id;
  final String nombre;
  final List<Subcategoria> subcategorias;

  Categoria({
    required this.id,
    required this.nombre,
    required this.subcategorias,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    final subs = (json['subcategorias'] as List<dynamic>? ?? [])
        .map((s) => Subcategoria.fromJson(s as Map<String, dynamic>))
        .toList();
    return Categoria(
      id: json['id'] as int,
      nombre: (json['nombre'] ?? '') as String,
      subcategorias: subs,
    );
  }
}
