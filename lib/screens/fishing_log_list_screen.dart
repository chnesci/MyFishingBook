import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fishlog/models/fishing_log.dart';
import 'package:fishlog/screens/edit_log_screen.dart';
import 'dart:io';

class FishingLogListScreen extends StatelessWidget {
  final String username;
  const FishingLogListScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Registros'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FishingLog>('fishingLogs').listenable(),
        builder: (context, Box<FishingLog> box, _) {
          final logs = box.values
              .where((log) => log.userId == username)
              .toList()
              .reversed
              .toList();

          if (logs.isEmpty) {
            return const Center(
              child: Text('Aún no tienes registros de pesca.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Desliza a la izquierda para eliminar o a la derecha para editar.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Dismissible(
                      key: Key(log.key.toString()),
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Lógica de confirmación para eliminar
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar Eliminación'),
                                content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (direction == DismissDirection.startToEnd) {
                          // Lógica para editar
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditLogScreen(logToEdit: log),
                            ),
                          );
                          return false; // No eliminar
                        }
                        return false;
                      },
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Eliminación de las fotos asociadas
                          try {
                            if (log.photoPath.isNotEmpty && await File(log.photoPath).exists()) {
                              await File(log.photoPath).delete();
                            }
                            if (log.lurePhotoPath.isNotEmpty && await File(log.lurePhotoPath).exists()) {
                              await File(log.lurePhotoPath).delete();
                            }
                          } catch (_) {
                            // Ignorar errores al eliminar archivos
                          }

                          await box.delete(log.key);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registro eliminado con éxito.')),
                            );
                          }
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navegación a la pantalla de edición al tocar la tarjeta
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditLogScreen(logToEdit: log),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pin_drop, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        log.location.isNotEmpty ? log.location : 'Lugar no especificado',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fecha: ${log.date != null ? log.date.toString().substring(0, 16) : 'Sin fecha'}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                                if (log.weather != null && log.weather!.isNotEmpty)
                                  Text(
                                    'Clima: ${log.weather}',
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                if (log.notes.isNotEmpty)
                                  Text(
                                    'Notas: ${log.notes}',
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                const SizedBox(height: 16),
                                if (log.photoPath.isNotEmpty || log.lurePhotoPath.isNotEmpty)
                                  GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    children: [
                                      if (log.photoPath.isNotEmpty && File(log.photoPath).existsSync())
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.file(
                                            File(log.photoPath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (log.lurePhotoPath.isNotEmpty && File(log.lurePhotoPath).existsSync())
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.file(
                                            File(log.lurePhotoPath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  ),
                                if (log.photoPath.isEmpty && log.lurePhotoPath.isEmpty)
                                  const Center(
                                    child: Text(
                                      'No hay fotos para este registro',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}