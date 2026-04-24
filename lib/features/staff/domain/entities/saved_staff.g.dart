// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedStaffAdapter extends TypeAdapter<SavedStaff> {
  @override
  final int typeId = 1;

  @override
  SavedStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedStaff(
      schoolCode: fields[0] as String,
      name: fields[1] as String,
      uniqueCode: fields[2] as String,
      profileImage: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedStaff obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.schoolCode)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.uniqueCode)
      ..writeByte(3)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
