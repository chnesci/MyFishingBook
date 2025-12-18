import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fishlog/models/user.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _secretAnswer1Controller = TextEditingController();
  final _secretAnswer2Controller = TextEditingController();
  final _secretAnswer3Controller = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  String? _errorMessage;
  bool _showQuestions = false;
  bool _showPasswordFields = false;

  Future<void> _resetPassword() async {
    final userBox = await Hive.openBox<User>('users');
    final String username = _usernameController.text;

    if (_showPasswordFields) {
      if (_formKey.currentState!.validate()) {
        final user = userBox.get(username);
        if (user != null) {
          user.password = _newPasswordController.text;
          await user.save();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contraseña restablecida con éxito.')),
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } else if (_showQuestions) {
      if (_formKey.currentState!.validate()) {
        final user = userBox.get(username);
        if (user != null) {
          if (user.secretAnswer1 == _secretAnswer1Controller.text &&
              user.secretAnswer2 == _secretAnswer2Controller.text &&
              user.secretAnswer3 == _secretAnswer3Controller.text) {
            setState(() {
              _showPasswordFields = true;
              _errorMessage = null;
            });
          } else {
            setState(() {
              _errorMessage = 'Una o más respuestas secretas son incorrectas.';
            });
          }
        }
      }
    } else {
      if (_formKey.currentState!.validate()) {
        if (userBox.containsKey(username)) {
          setState(() {
            _showQuestions = true;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'El usuario no existe.';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _secretAnswer1Controller.dispose();
    _secretAnswer2Controller.dispose();
    _secretAnswer3Controller.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé mi contraseña'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showQuestions) ...[
                  const Text(
                    'Ingresa tu usuario para comenzar a restablecer tu contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu usuario';
                      }
                      return null;
                    },
                  ),
                ] else if (_showQuestions && !_showPasswordFields) ...[
                  const Text(
                    'Responde las preguntas de seguridad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¿Cuál era el nombre de tu primera mascota?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _secretAnswer1Controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu respuesta',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu respuesta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Cómo te decían en la infancia (sobrenombre)?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _secretAnswer2Controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu respuesta',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu respuesta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Cuál es el nombre de tu mejor amigo?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _secretAnswer3Controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu respuesta',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu respuesta';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  const Text(
                    'Ingresa tu nueva contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una contraseña';
                      }
                      List<String> errors = [];
                      if (value.length < 8) {
                        errors.add('La contraseña debe tener al menos 8 caracteres.');
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        errors.add('Debe contener al menos una letra mayúscula.');
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        errors.add('Debe contener al menos una letra minúscula.');
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        errors.add('Debe contener al menos un número.');
                      }
                      if (errors.isNotEmpty) {
                        return errors.join('\n');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirma tu nueva contraseña';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text(
                    _showPasswordFields ? 'Guardar nueva contraseña' : 'Continuar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}