
class Libro {
  int? id;
  String titulo;
  String autor;
  int anio;
  String genero;
  bool leido;

  Libro({
    this.id,
    required this.titulo,
    required this.autor,
    required this.anio,
    required this.genero,
    this.leido = false,
  });

  // Convierte el objeto a un mapa para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'anio': anio,
      'genero': genero,
      'leido': leido ? 1 : 0,
    };
  }

  // Crea un objeto Libro desde un mapa de SQLite
  factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      id: map['id'],
      titulo: map['titulo'],
      autor: map['autor'],
      anio: map['anio'],
      genero: map['genero'],
      leido: map['leido'] == 1,
    );
  }
}
