import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password;

  @HiveField(2)
  late String secretAnswer1;

  @HiveField(3)
  late String secretAnswer2;

  @HiveField(4)
  late String secretAnswer3;

  @HiveField(5)
  late String name; // Agregado

  @HiveField(6)
  late String email; // Agregado

  User({
    required this.username,
    required this.password,
    required this.secretAnswer1,
    required this.secretAnswer2,
    required this.secretAnswer3,
    required this.name, // Agregado
    required this.email, // Agregado
  });
}
