import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fishlog/models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    final userBox = await Hive.openBox<User>('users');
    final bool hasUsers = userBox.isNotEmpty;

    // Retraso para que el usuario pueda ver la pantalla de carga
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (hasUsers) {
      // Si hay usuarios, navega a la pantalla de login (donde se puede manejar el login automático)
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Si no hay usuarios, navega directamente a la pantalla de registro
      Navigator.of(context).pushReplacementNamed('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF3399FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icon/icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'FishLog',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Aplicación para registros de pesca',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Created by Cristián Nesci',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}