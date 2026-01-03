import 'dart:io';
import 'package:hive/hive.dart';
import 'package:fishlog/models/user.dart';
import 'package:fishlog/utils/auth.dart';

// Usage:
// dart run tools/migrate_passwords.dart --hive-path "C:\path\to\hive_dir"

Future<void> main(List<String> args) async {
  final argMap = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--')) {
      final name = a.substring(2);
      if (i + 1 < args.length) argMap[name] = args[i + 1];
    }
  }

  final hivePath = argMap['hive-path'] ?? '';
  if (hivePath.isEmpty) {
    stdout.writeln('Error: necesitas pasar --hive-path con el directorio donde están los archivos Hive (ej: app data).');
    exit(1);
  }
  final verbose = argMap['verbose'] == 'true';

  Hive.init(hivePath);
  Hive.registerAdapter(UserAdapter());

  final box = await Hive.openBox<User>('users');
  final keys = box.keys.toList();

  var migrated = 0;
  for (final key in keys) {
    final u = box.get(key);
    if (u == null) continue;
    final hasPlain = u.password.isNotEmpty;
    final hasHash = (u.passwordHash != null && u.passwordHash!.isNotEmpty);
    if (hasPlain && !hasHash) {
      final hash = AuthUtil.hashPassword(u.password);
      u.passwordHash = hash;
      u.password = '';
      await u.save();
      migrated++;
      if (verbose) {
        stdout.writeln('Migrated user ${u.username} (key=$key)');
      }
    }
  }

  if (verbose) {
    stdout.writeln('Migration complete. Total migrated: $migrated');
  }
  await box.close();
}
