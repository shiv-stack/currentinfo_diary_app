import 'package:hive/hive.dart';
import '../../domain/entities/saved_staff.dart';

abstract class StaffLocalDataSource {
  Future<void> saveStaff(SavedStaff staff);
  Future<List<SavedStaff>> getSavedStaff();
  Future<void> removeStaff(String uniqueCode);
}

class StaffLocalDataSourceImpl implements StaffLocalDataSource {
  static const String boxName = 'saved_staff';

  @override
  Future<void> saveStaff(SavedStaff staff) async {
    final box = await Hive.openBox<SavedStaff>(boxName);
    
    // Check if staff already exists
    final existingIndex = box.values.toList().indexWhere(
      (s) => s.uniqueCode == staff.uniqueCode && s.schoolCode == staff.schoolCode
    );

    if (existingIndex != -1) {
      await box.putAt(existingIndex, staff);
    } else {
      // Limit to 5 users
      if (box.length >= 5) {
        await box.deleteAt(0); // Remove oldest
      }
      await box.add(staff);
    }
  }

  @override
  Future<List<SavedStaff>> getSavedStaff() async {
    final box = await Hive.openBox<SavedStaff>(boxName);
    return box.values.toList();
  }

  @override
  Future<void> removeStaff(String uniqueCode) async {
    final box = await Hive.openBox<SavedStaff>(boxName);
    final keyToDelete = box.keys.firstWhere(
      (k) => box.get(k)?.uniqueCode == uniqueCode,
      orElse: () => null,
    );
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }
}
