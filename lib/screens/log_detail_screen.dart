import 'package:flutter/material.dart';
import 'package:fishlog/models/fishing_log.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class LogDetailScreen extends StatelessWidget {
  final FishingLog fishingLog;
  const LogDetailScreen({super.key, required this.fishingLog});

  void _launchMapsUrl() async {
    final lat = fishingLog.latitude;
    final lon = fishingLog.longitude;
    final url = Uri.parse('http://maps.google.com/?q=$lat,$lon');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fishingLog.location)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fishingLog.photoPath.isNotEmpty &&
                File(fishingLog.photoPath).existsSync())
              Image.file(File(fishingLog.photoPath), fit: BoxFit.cover)
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('No hay foto del pez')),
              ),
            const SizedBox(height: 16),
            if (fishingLog.date != null) ...[
              Text(
                'Fecha: ${fishingLog.date!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Hora: ${fishingLog.date!.toLocal().toString().substring(11, 16)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            Text(
              'Clima: ${fishingLog.weather}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Ubicación:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: _launchMapsUrl,
                ),
                Text(
                  '${fishingLog.latitude.toStringAsFixed(4)}, ${fishingLog.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Señuelo: ${fishingLog.lure}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (fishingLog.lurePhotoPath.isNotEmpty &&
                File(fishingLog.lurePhotoPath).existsSync())
              Image.file(File(fishingLog.lurePhotoPath), fit: BoxFit.cover)
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('No hay foto del señuelo')),
              ),
            const SizedBox(height: 16),
            Text('Notas:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(fishingLog.notes, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
