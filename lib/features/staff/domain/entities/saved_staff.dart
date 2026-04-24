import 'package:hive/hive.dart';

part 'saved_staff.g.dart';

@HiveType(typeId: 1)
class SavedStaff extends HiveObject {
  @HiveField(0)
  final String schoolCode;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String uniqueCode;

  @HiveField(3)
  final String? profileImage;

  @HiveField(4)
  final String? assignClass;

  SavedStaff({
    required this.schoolCode,
    required this.name,
    required this.uniqueCode,
    this.profileImage,
    this.assignClass,
  });
}
