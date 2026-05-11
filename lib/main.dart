
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'libro.dart';
import 'agregar_editar_libro.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Biblioteca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: ListaLibrosScreen(),
    );
  }
}

// ─────────────────────────────────────────
// PANTALLA PRINCIPAL: Lista de libros
// ─────────────────────────────────────────
class ListaLibrosScreen extends StatefulWidget {
  @override
  _ListaLibrosScreenState createState() => _ListaLibrosScreenState();
}

class _ListaLibrosScreenState extends State<ListaLibrosScreen> {
  List<Libro> _libros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarLibros(); // Carga los libros al abrir la app
  }

  // Carga todos los libros desde SQLite
  Future<void> _cargarLibros() async {
    final libros = await DatabaseHelper().getLibros();
    setState(() {
      _libros = libros;
      _isLoading = false;
    });
  }

  // Elimina un libro de SQLite y recarga la lista
  Future<void> _eliminarLibro(Libro libro) async {
    await DatabaseHelper().deleteLibro(libro.id!);
    _cargarLibros();
  }

  // Cambia el estado leído/no leído del libro
  Future<void> _cambiarEstadoLeido(Libro libro) async {
    libro.leido = !libro.leido;
    await DatabaseHelper().updateLibro(libro);
    _cargarLibros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 Mi Biblioteca Personal'),
        actions: [
          // Botón de búsqueda en la barra superior
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _mostrarBuscador(context),
          ),
        ],
      ),

      // CUERPO: muestra spinner, mensaje vacío, o lista
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _libros.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay libros.\n¡Agrega uno con el botón +!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _libros.length,
        itemBuilder: (context, index) {
          final libro = _libros[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              // Ícono verde si leído, azul si no
              leading: Icon(
                libro.leido ? Icons.check_circle : Icons.book,
                color: libro.leido ? Colors.green : Colors.blue,
                size: 32,
              ),
              title: Text(
                libro.titulo,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${libro.autor} • ${libro.anio}\n${libro.genero}',
              ),
              isThreeLine: true,

              // Menú de 3 puntos: Editar o Eliminar
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'editar') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgregarEditarLibro(libro: libro),
                      ),
                    );
                    if (result == true) _cargarLibros();
                  } else if (value == 'eliminar') {
                    // Pide confirmación antes de eliminar
                    _confirmarEliminar(context, libro);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),

              // Tap sobre el libro = marcar como leído/no leído
              onTap: () => _cambiarEstadoLeido(libro),
            ),
          );
        },
      ),

      // Botón flotante para agregar un nuevo libro
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Agregar libro',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AgregarEditarLibro()),
          );
          if (result == true) _cargarLibros();
        },
      ),
    );
  }

  // Diálogo de confirmación antes de eliminar
  void _confirmarEliminar(BuildContext context, Libro libro) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar libro'),
        content: Text('¿Seguro que quieres eliminar "${libro.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _eliminarLibro(libro);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Diálogo de búsqueda
  void _mostrarBuscador(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        String busqueda = '';
        return AlertDialog(
          title: Text('🔍 Buscar libro'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => busqueda = value,
            decoration: InputDecoration(
              hintText: 'Escribe un título o autor...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cargarLibros(); // Limpia la búsqueda
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (busqueda.isNotEmpty) {
                  // ✅ CORRECCIÓN: "final resultados" (con espacio)
                  final resultados =
                  await DatabaseHelper().buscarLibros(busqueda);
                  setState(() => _libros = resultados);
                } else {
                  _cargarLibros();
                }
              },
              child: Text('Buscar'),
            ),
          ],
        );
      },
    );
  }
}