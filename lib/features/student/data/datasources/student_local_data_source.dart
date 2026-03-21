import 'package:hive/hive.dart';
import '../../domain/entities/saved_student.dart';

abstract class StudentLocalDataSource {
  Future<void> saveStudent(SavedStudent student);
  Future<List<SavedStudent>> getSavedStudents();
  Future<void> removeStudent(String uniqueCode);
}

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  static const String boxName = 'saved_students';

  @override
  Future<void> saveStudent(SavedStudent student) async {
    final box = await Hive.openBox<SavedStudent>(boxName);
    
    // Check if player already exists
    final existingIndex = box.values.toList().indexWhere(
      (s) => s.uniqueCode == student.uniqueCode && s.schoolCode == student.schoolCode
    );

    if (existingIndex != -1) {
      await box.putAt(existingIndex, student);
    } else {
      // Limit to 5 users
      if (box.length >= 5) {
        await box.deleteAt(0); // Remove oldest
      }
      await box.add(student);
    }
  }

  @override
  Future<List<SavedStudent>> getSavedStudents() async {
    final box = await Hive.openBox<SavedStudent>(boxName);
    return box.values.toList();
  }

  @override
  Future<void> removeStudent(String uniqueCode) async {
    final box = await Hive.openBox<SavedStudent>(boxName);
    final keyToDelete = box.keys.firstWhere(
      (k) => box.get(k)?.uniqueCode == uniqueCode,
      orElse: () => null,
    );
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }
}
