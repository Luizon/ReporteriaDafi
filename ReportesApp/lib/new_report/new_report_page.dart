import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'new_report_controller.dart';

class NewReportPage extends ConsumerStatefulWidget {
  const NewReportPage({super.key});

  @override
  ConsumerState<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends ConsumerState<NewReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _folioController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _shootPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  bool _isFormComplete() {
    return _folioController.text.isNotEmpty &&
      _titleController.text.isNotEmpty &&
      _descController.text.isNotEmpty &&
      _image != null;
  }

  Future<bool> _confirmExit() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("¿Seguro que quieres salir?"),
            content: const Text("Perderás el progreso de tu reporte."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Salir"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(newReportControllerProvider);

    return PopScope(
  canPop: false, // bloquea el pop automático
  onPopInvokedWithResult : (didPop, result) async {
    if (didPop) return;
    final exit = await _confirmExit();
    if (exit) {
      Navigator.pop(context);
    }
  },
  child: Scaffold(
    appBar: AppBar(
      title: const Text('Nuevo Reporte'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (await _confirmExit()) {
            Navigator.pop(context);
          }
        },
      ),
    ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _folioController,
                  decoration: const InputDecoration(labelText: 'Folio'),
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                _image == null
                    ? const Text("No hay imagen seleccionada")
                    : Image.file(_image!, height: 150),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo_library),
                              SizedBox(width: 8),
                              Text("Seleccionar imagen"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    ElevatedButton(
                      onPressed: _shootPhoto,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: reportState.isLoading || !_isFormComplete()
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() && _image != null) {
                            // Mostrar modal de carga
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Subiendo reporte..."),
                                  ],
                                ),
                              ),
                            );

                            try {
                              Response? response = await ref
                                  .read(newReportControllerProvider.notifier)
                                  .submitReport(
                                    folio: _folioController.text,
                                    title: _titleController.text,
                                    description: _descController.text,
                                    image: _image!,
                                  );
                              if(response == null) {
                                throw Exception("Ocurrio un error");
                              }

                              Navigator.pop(context); // cerrar modal de carga

                              // Mostrar modal de éxito
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AlertDialog(
                                  title: const Text("Éxito",
                                      style: TextStyle(color: Colors.green)),
                                  content: const Text("El reporte se ha creado correctamente."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // cerrar modal
                                        Navigator.pop(context); // salir de NewReportPage
                                      },
                                      child: const Text("Aceptar"),
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(context); // cerrar modal de carga

                              // Mostrar modal de error
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AlertDialog(
                                  title: const Text("Error",
                                      style: TextStyle(color: Colors.red)),
                                  content: Text("No se pudo subir el reporte: $e"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // cerrar modal
                                        Navigator.pop(context); // salir de NewReportPage
                                      },
                                      child: const Text("Aceptar"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                  child: reportState.isLoading
                      ? const CircularProgressIndicator()
                      : _isFormComplete()
                        ? const Text("Guardar reporte")
                        : const Text("Completa todos los campos"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}