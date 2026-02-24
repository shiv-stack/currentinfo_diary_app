import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSchoolCode(String code);
  Future<String?> getCachedSchoolCode();
  Future<void> cacheSchoolInfo(SchoolModel school);
  Future<SchoolModel?> getCachedSchoolInfo();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _schoolCodeKey = 'cached_school_code';
  static const String _schoolInfoKey = 'cached_school_info';

  @override
  Future<void> cacheSchoolCode(String code) async {
    await sharedPreferences.setString(_schoolCodeKey, code);
  }

  @override
  Future<String?> getCachedSchoolCode() async {
    return sharedPreferences.getString(_schoolCodeKey);
  }

  @override
  Future<void> cacheSchoolInfo(SchoolModel school) async {
    await sharedPreferences.setString(
      _schoolInfoKey,
      jsonEncode(school.toJson()),
    );
  }

  @override
  Future<SchoolModel?> getCachedSchoolInfo() async {
    final jsonString = sharedPreferences.getString(_schoolInfoKey);
    if (jsonString != null) {
      return SchoolModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(_schoolCodeKey);
    await sharedPreferences.remove(_schoolInfoKey);
  }
}
