import 'package:hive/hive.dart';

part 'fishing_log.g.dart';

@HiveType(typeId: 0)
class FishingLog extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String location; // Nombre personalizado del lugar

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final DateTime? date;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final String photoPath;

  @HiveField(7)
  final String lurePhotoPath;

  @HiveField(8)
  final bool isCatch;

  @HiveField(9)
  final String? fishSpecies;

  @HiveField(10)
  final double? fishWeight;

  @HiveField(11)
  final double? fishLength;

  @HiveField(12)
  final String? lureType;

  @HiveField(13)
  final String? lureColor;

  @HiveField(14)
  final double? temperature;

  @HiveField(15)
  final String? conditions;

  @HiveField(16)
  final String? weather;

  @HiveField(17)
  final String? lure;

  @HiveField(18)
  final String? geocodedAddress; // Nuevo campo para la dirección oficial

  FishingLog({
    required this.userId,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.date,
    required this.notes,
    required this.photoPath,
    required this.lurePhotoPath,
    required this.isCatch,
    this.fishSpecies,
    this.fishWeight,
    this.fishLength,
    this.lureType,
    this.lureColor,
    this.temperature,
    this.conditions,
    this.weather,
    this.lure,
    this.geocodedAddress, // Añadido al constructor
  });
}
