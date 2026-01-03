import 'package:bcrypt/bcrypt.dart';

class AuthUtil {
  /// Genera un hash bcrypt para la contraseña proporcionada.
  static String hashPassword(String password) {
    final String salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  /// Verifica la contraseña contra el hash almacenado.
  static bool verifyPassword(String password, String hashed) {
    try {
      return BCrypt.checkpw(password, hashed);
    } catch (_) {
      return false;
    }
  }
}
