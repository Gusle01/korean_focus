// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_collectible.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OwnedCollectibleAdapter extends TypeAdapter<OwnedCollectible> {
  @override
  final int typeId = 1;

  @override
  OwnedCollectible read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OwnedCollectible(
      id: fields[0] as String,
      defId: fields[1] as String,
      city: fields[2] as String,
      categoryIndex: fields[3] as int,
      name: fields[4] as String,
      emoji: fields[5] as String,
      acquiredAt: fields[6] as DateTime,
      originName: fields[7] as String,
      destName: fields[8] as String,
      transportIndex: fields[9] as int,
      durationSeconds: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OwnedCollectible obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.defId)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.categoryIndex)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.emoji)
      ..writeByte(6)
      ..write(obj.acquiredAt)
      ..writeByte(7)
      ..write(obj.originName)
      ..writeByte(8)
      ..write(obj.destName)
      ..writeByte(9)
      ..write(obj.transportIndex)
      ..writeByte(10)
      ..write(obj.durationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedCollectibleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
