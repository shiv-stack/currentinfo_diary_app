import 'package:hive/hive.dart';

part 'saved_student.g.dart';

@HiveType(typeId: 0)
class SavedStudent extends HiveObject {
  @HiveField(0)
  final String schoolCode;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String uniqueCode;

  @HiveField(3)
  final String? studentClass;

  @HiveField(4)
  final String? profileImage;

  SavedStudent({
    required this.schoolCode,
    required this.name,
    required this.uniqueCode,
    this.studentClass,
    this.profileImage,
  });
}
