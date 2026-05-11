import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'libro.dart';

class DatabaseHelper {
  // Singleton: solo existe una instancia en toda la app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter que devuelve la base de datos (la crea si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'biblioteca.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Crea la tabla cuando la app se instala por primera vez
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE libros(
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        autor  TEXT NOT NULL,
        anio   INTEGER,
        genero TEXT,
        leido  INTEGER DEFAULT 0
      )
    ''');
  }

  // ➕ CREAR: Insertar un libro nuevo
  Future<int> insertLibro(Libro libro) async {
    final db = await database;
    return await db.insert('libros', libro.toMap());
  }

  // 📋 LEER: Obtener todos los libros
  Future<List<Libro>> getLibros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('libros');
    return List.generate(maps.length, (i) => Libro.fromMap(maps[i]));
  }

  // ✏️ ACTUALIZAR: Modificar un libro existente
  Future<int> updateLibro(Libro libro) async {
    final db = await database;
    return await db.update(
      'libros',
      libro.toMap(),
      where: 'id = ?',
      whereArgs: [libro.id],
    );
  }

  // 🗑️ ELIMINAR: Borrar un libro por su id
  Future<int> deleteLibro(int id) async {
    final db = await database;
    return await db.delete(
      'libros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔍 BUSCAR: Filtrar libros por título o autor
  Future<List<Libro>> buscarLibros(String texto) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'libros',
      where: 'titulo LIKE ? OR autor LIKE ?',
      whereArgs: ['%$texto%', '%$texto%'],
    );
    return List.generate(maps.length, (i) => Libro.fromMap(maps[i]));
  }
}