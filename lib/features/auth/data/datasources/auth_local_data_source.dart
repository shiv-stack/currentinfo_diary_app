import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSchoolCode(String code);
  Future<String?> getCachedSchoolCode();
  Future<void> cacheSchoolInfo(SchoolModel school);
  Future<SchoolModel?> getCachedSchoolInfo();
  Future<void> cacheStudentId(String studentId);
  Future<String?> getCachedStudentId();
  Future<void> cacheStudentCredentials(
    String schoolCode,
    String name,
    String password,
  );
  Future<Map<String, String>?> getCachedStudentCredentials(String schoolCode);
  Future<void> cacheActiveStudentCredentials(String name, String password);
  Future<Map<String, String>?> getActiveStudentCredentials();
  Future<void> cacheSession(String session);
  Future<String?> getCachedSession();
  Future<void> cacheOnlineFeeSubmit(String value);
  Future<bool> isOnlineFeeSubmitEnabled();
  Future<void> cacheFeeSoftware(String value);
  Future<String?> getCachedFeeSoftware();
  Future<void> cacheLeaveOption(String value);
  Future<bool> isLeaveOptionEnabled();
  Future<void> clearActiveStudentSession();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _schoolCodeKey = 'cached_school_code';
  static const String _schoolInfoKey = 'cached_school_info';
  static const String _studentIdKey = 'cached_student_id';
  static const String _studentCredentialsKey = 'cached_student_credentials';
  static const String _activeStudentKey = 'active_student_session';
  static const String _sessionKey = 'cached_session';
  static const String _feeSubmitKey = 'fee_submit_enabled';
  static const String _feeSoftwareKey = 'fee_software_type';
  static const String _leaveOptionKey = 'leave_option_enabled';

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
  Future<void> cacheStudentId(String studentId) async {
    await sharedPreferences.setString(_studentIdKey, studentId);
  }

  @override
  Future<String?> getCachedStudentId() async {
    return sharedPreferences.getString(_studentIdKey);
  }

  @override
  Future<void> cacheStudentCredentials(
    String schoolCode,
    String name,
    String password,
  ) async {
    final existingData = sharedPreferences.getString(_studentCredentialsKey);
    Map<String, dynamic> credentialsMap = {};
    if (existingData != null) {
      credentialsMap = jsonDecode(existingData);
    }
    credentialsMap[schoolCode] = {'name': name, 'password': password};
    await sharedPreferences.setString(
      _studentCredentialsKey,
      jsonEncode(credentialsMap),
    );
  }

  @override
  Future<Map<String, String>?> getCachedStudentCredentials(
    String schoolCode,
  ) async {
    final data = sharedPreferences.getString(_studentCredentialsKey);
    if (data != null) {
      final Map<String, dynamic> fullMap = jsonDecode(data);
      if (fullMap.containsKey(schoolCode)) {
        final Map<String, dynamic> studentData = fullMap[schoolCode];
        return {
          'name': studentData['name'] as String,
          'password': studentData['password'] as String,
        };
      }
    }
    return null;
  }

  @override
  Future<void> cacheActiveStudentCredentials(
    String name,
    String password,
  ) async {
    final data = {'name': name, 'password': password};
    await sharedPreferences.setString(_activeStudentKey, jsonEncode(data));
  }

  @override
  Future<Map<String, String>?> getActiveStudentCredentials() async {
    final data = sharedPreferences.getString(_activeStudentKey);
    if (data != null) {
      final Map<String, dynamic> parsed = jsonDecode(data);
      return {
        'name': parsed['name'] as String,
        'password': parsed['password'] as String,
      };
    }
    return null;
  }

  @override
  Future<void> cacheSession(String session) async {
    await sharedPreferences.setString(_sessionKey, session);
  }

  @override
  Future<String?> getCachedSession() async {
    return sharedPreferences.getString(_sessionKey);
  }

  @override
  Future<void> cacheOnlineFeeSubmit(String value) async {
    await sharedPreferences.setString(_feeSubmitKey, value);
  }

  @override
  Future<bool> isOnlineFeeSubmitEnabled() async {
    final val = sharedPreferences.getString(_feeSubmitKey);
    return val == "Yes";
  }

  @override
  Future<void> cacheFeeSoftware(String value) async {
    await sharedPreferences.setString(_feeSoftwareKey, value);
  }

  @override
  Future<String?> getCachedFeeSoftware() async {
    return sharedPreferences.getString(_feeSoftwareKey);
  }

  @override
  Future<void> cacheLeaveOption(String value) async {
    await sharedPreferences.setString(_leaveOptionKey, value);
  }

  @override
  Future<bool> isLeaveOptionEnabled() async {
    final val = sharedPreferences.getString(_leaveOptionKey);
    return val == "Active";
  }

  @override
  Future<void> clearActiveStudentSession() async {
    await sharedPreferences.remove(_activeStudentKey);
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(_schoolCodeKey);
    await sharedPreferences.remove(_schoolInfoKey);
    await sharedPreferences.remove(_studentIdKey);
    await sharedPreferences.remove(_studentCredentialsKey);
    await sharedPreferences.remove(_activeStudentKey);
    await sharedPreferences.remove(_sessionKey);
    await sharedPreferences.remove(_feeSubmitKey);
    await sharedPreferences.remove(_feeSoftwareKey);
    await sharedPreferences.remove(_leaveOptionKey);
  }
}
