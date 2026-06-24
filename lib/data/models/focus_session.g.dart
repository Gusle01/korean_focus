// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 0;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      id: fields[0] as String,
      originName: fields[1] as String,
      destName: fields[2] as String,
      transportIndex: fields[3] as int,
      plannedSeconds: fields[4] as int,
      focusedSeconds: fields[5] as int,
      startedAt: fields[6] as DateTime,
      completed: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originName)
      ..writeByte(2)
      ..write(obj.destName)
      ..writeByte(3)
      ..write(obj.transportIndex)
      ..writeByte(4)
      ..write(obj.plannedSeconds)
      ..writeByte(5)
      ..write(obj.focusedSeconds)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
