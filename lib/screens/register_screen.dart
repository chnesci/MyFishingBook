import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fishlog/models/user.dart';
import 'package:fishlog/utils/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController(); // Agregado
  final _emailController = TextEditingController(); // Agregado
  final _secretAnswer1Controller = TextEditingController();
  final _secretAnswer2Controller = TextEditingController();
  final _secretAnswer3Controller = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final userBox = await Hive.openBox<User>('users');
      final String username = _usernameController.text;
      final String password = _passwordController.text;
      final String name = _nameController.text; // Agregado
      final String email = _emailController.text; // Agregado
      final String secretAnswer1 = _secretAnswer1Controller.text;
      final String secretAnswer2 = _secretAnswer2Controller.text;
      final String secretAnswer3 = _secretAnswer3Controller.text;

      if (userBox.containsKey(username)) {
        setState(() {
          _errorMessage = 'El nombre de usuario ya existe.';
        });
        return;
      }

      // Store hashed password, avoid keeping plaintext in storage
      final passwordHash = AuthUtil.hashPassword(password);
      final newUser = User(
        username: username,
        password: '', // clear plaintext password
        name: name, // Agregado
        email: email, // Agregado
        secretAnswer1: secretAnswer1,
        secretAnswer2: secretAnswer2,
        secretAnswer3: secretAnswer3,
        passwordHash: passwordHash,
      );
      await userBox.put(username, newUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. ¡Inicia sesión!'),
        ),
      );
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose(); // Agregado
    _emailController.dispose(); // Agregado
    _secretAnswer1Controller.dispose();
    _secretAnswer2Controller.dispose();
    _secretAnswer3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bienvenido a FishLog',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController, // Agregado
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo', // Agregado
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController, // Agregado
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico', // Agregado
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa una contraseña';
                    }

                    List<String> errors = [];
                    if (value.length < 8) {
                      errors.add(
                        'La contraseña debe tener al menos 8 caracteres.',
                      );
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
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    prefixIcon: Icon(Icons.question_answer),
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
                    prefixIcon: Icon(Icons.question_answer),
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
                    prefixIcon: Icon(Icons.question_answer),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu respuesta';
                    }
                    return null;
                  },
                ),
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
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Registrar'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('¿Ya tienes una cuenta? Inicia sesión.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
