
import 'package:flutter/material.dart';
import 'libro.dart';
import 'database_helper.dart';

class AgregarEditarLibro extends StatefulWidget {
final Libro? libro;

const AgregarEditarLibro({Key? key, this.libro}) : super(key: key);

@override
_AgregarEditarLibroState createState() => _AgregarEditarLibroState();
}

class _AgregarEditarLibroState extends State<AgregarEditarLibro> {
final _formKey = GlobalKey<FormState>();

late TextEditingController _tituloController;
late TextEditingController _autorController;
late TextEditingController _anioController;
late TextEditingController _generoController;

@override
void initState() {
super.initState();

_tituloController =
TextEditingController(text: widget.libro?.titulo ?? '');

_autorController =
TextEditingController(text: widget.libro?.autor ?? '');

_anioController = TextEditingController(
text: widget.libro != null
? widget.libro!.anio.toString()
    : '');

_generoController =
TextEditingController(text: widget.libro?.genero ?? '');
}

@override
void dispose() {
_tituloController.dispose();
_autorController.dispose();
_anioController.dispose();
_generoController.dispose();
super.dispose();
}

Future<void> _guardar() async {
if (_formKey.currentState!.validate()) {
try {
final libro = Libro(
id: widget.libro?.id,
titulo: _tituloController.text.trim(),
autor: _autorController.text.trim(),
anio: int.tryParse(_anioController.text) ?? 0,
genero: _generoController.text.trim(),
);

int resultado;

if (widget.libro == null) {
resultado = await DatabaseHelper().insertLibro(libro);
print("✅ Libro insertado ID: $resultado");
} else {
resultado = await DatabaseHelper().updateLibro(libro);
print("✏️ Libro actualizado: $resultado");
}

Navigator.pop(context, true);
} catch (e) {
print("❌ Error al guardar: $e");

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error al guardar el libro'),
backgroundColor: Colors.red,
),
);
}
}
}

@override
Widget build(BuildContext context) {
final esEdicion = widget.libro != null;

return Scaffold(
appBar: AppBar(
title: Text(
esEdicion ? '✏️ Editar libro' : '➕ Agregar libro',
),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Form(
key: _formKey,
child: Column(
children: [

// TÍTULO
TextFormField(
controller: _tituloController,
decoration: const InputDecoration(
labelText: 'Título *',
prefixIcon: Icon(Icons.book),
border: OutlineInputBorder(),
),
validator: (value) =>
value == null || value.isEmpty
? 'El título es obligatorio'
    : null,
),

const SizedBox(height: 12),

// AUTOR
TextFormField(
controller: _autorController,
decoration: const InputDecoration(
labelText: 'Autor *',
prefixIcon: Icon(Icons.person),
border: OutlineInputBorder(),
),
validator: (value) =>
value == null || value.isEmpty
? 'El autor es obligatorio'
    : null,
),

const SizedBox(height: 12),

// AÑO
TextFormField(
controller: _anioController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: 'Año *',
prefixIcon: Icon(Icons.calendar_today),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.isEmpty) {
return 'El año es obligatorio';
}
final anio = int.tryParse(value);
if (anio == null) return 'Ingrese un número válido';
if (anio < 1000 || anio > 2100) {
return 'Año entre 1000 y 2100';
}
return null;
},
),

const SizedBox(height: 12),

// GÉNERO
TextFormField(
controller: _generoController,
decoration: const InputDecoration(
labelText: 'Género',
prefixIcon: Icon(Icons.category),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 20),

// BOTÓN GUARDAR
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
icon: const Icon(Icons.save),
label: const Text('Guardar libro'),
onPressed: _guardar,
),
),

const SizedBox(height: 10),

// BOTÓN CANCELAR
SizedBox(
width: double.infinity,
child: OutlinedButton(
child: const Text('Cancelar'),
onPressed: () => Navigator.pop(context),
),
),
],
),
),
),
);
}
}

