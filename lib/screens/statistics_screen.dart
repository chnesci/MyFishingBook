import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  final String username;

  const StatisticsScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Avanzadas'),
      ),
      body: const Center(
        child: Text('Próximamente: ¡Estadísticas detalladas de pesca!'),
      ),
    );
  }
}
