// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fishing_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FishingLogAdapter extends TypeAdapter<FishingLog> {
  @override
  final int typeId = 0;

  @override
  FishingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FishingLog(
      userId: fields[0] as String,
      location: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      date: fields[4] as DateTime?,
      notes: fields[5] as String,
      photoPath: fields[6] as String,
      lurePhotoPath: fields[7] as String,
      isCatch: fields[8] as bool,
      fishSpecies: fields[9] as String?,
      fishWeight: fields[10] as double?,
      fishLength: fields[11] as double?,
      lureType: fields[12] as String?,
      lureColor: fields[13] as String?,
      temperature: fields[14] as double?,
      conditions: fields[15] as String?,
      weather: fields[16] as String?,
      lure: fields[17] as String?,
      geocodedAddress: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FishingLog obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.lurePhotoPath)
      ..writeByte(8)
      ..write(obj.isCatch)
      ..writeByte(9)
      ..write(obj.fishSpecies)
      ..writeByte(10)
      ..write(obj.fishWeight)
      ..writeByte(11)
      ..write(obj.fishLength)
      ..writeByte(12)
      ..write(obj.lureType)
      ..writeByte(13)
      ..write(obj.lureColor)
      ..writeByte(14)
      ..write(obj.temperature)
      ..writeByte(15)
      ..write(obj.conditions)
      ..writeByte(16)
      ..write(obj.weather)
      ..writeByte(17)
      ..write(obj.lure)
      ..writeByte(18)
      ..write(obj.geocodedAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
