// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_student.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedStudentAdapter extends TypeAdapter<SavedStudent> {
  @override
  final int typeId = 0;

  @override
  SavedStudent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedStudent(
      schoolCode: fields[0] as String,
      name: fields[1] as String,
      uniqueCode: fields[2] as String,
      studentClass: fields[3] as String?,
      profileImage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedStudent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.schoolCode)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.uniqueCode)
      ..writeByte(3)
      ..write(obj.studentClass)
      ..writeByte(4)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedStudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
