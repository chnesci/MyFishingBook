import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/fishing_log.dart';
import '../models/user.dart';
import '../utils/theme_provider.dart';
import 'statistics_screen.dart'; // Importar la nueva pantalla

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  int totalCatches = 0;
  int totalTrips = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userBox = Hive.box<User>('users');
    final logBox = Hive.box<FishingLog>('fishingLogs');

    currentUser = userBox.get(widget.username);

    if (currentUser != null) {
      final userLogs = logBox.values.where(
        (log) => log.userId == widget.username,
      );
      totalTrips = userLogs.length;
      totalCatches = userLogs.where((log) => log.isCatch).length;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de edición de perfil pendiente.'),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es permanente y eliminará todos tus datos.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                final fishingLogBox = Hive.box<FishingLog>('fishingLogs');
                final userLogsKeys = fishingLogBox.values
                    .where((log) => log.userId == widget.username)
                    .map((e) => e.key)
                    .toList();
                await fishingLogBox.deleteAll(userLogsKeys);
                final userBox = Hive.box<User>('users');
                await userBox.delete(widget.username);
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (Route<dynamic> route) => false,
                      );
                    }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _showDeleteUserDialog(context),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentUser!.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          currentUser!.email,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Estadísticas de Pesca',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.water),
                    title: const Text('Viajes de pesca'),
                    trailing: Text(
                      '$totalTrips',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.catching_pokemon),
                    title: const Text('Capturas registradas'),
                    trailing: Text(
                      '$totalCatches',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Estadísticas Avanzadas'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsScreen(username: widget.username),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Apariencia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Modo Oscuro'),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
