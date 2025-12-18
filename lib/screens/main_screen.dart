import 'package:flutter/material.dart';


class MainScreen extends StatelessWidget {
  final String username;
  const MainScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FishLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile', arguments: username);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, $username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/new_log', arguments: username);
                },
                child: const Text('Nuevo Registro'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/fishing_log_list', arguments: username);
                },
                child: const Text('Mis Registros'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Created by Cristián Nesci',
                            style: TextStyle(color: Colors.white.withAlpha(128)),
            ),
          ],
        ),
      ),
    );
  }
}
