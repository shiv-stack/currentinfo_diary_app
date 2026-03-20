import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/student_model.dart';

abstract class StudentRemoteDataSource {
  Future<StudentModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<List<dynamic>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
  });

  Future<List<dynamic>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  });
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl({required this.dio});

  @override
  Future<StudentModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Name': name,
        'Profession': 'Student',
        'studentc': 'Student',
        'Unique_Code': uniqueCode,
      });

      final response = await dio.post(
        AppUrls.studentLogin(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        if (data.isNotEmpty) {
          final firstItem = data[0] as Map<String, dynamic>;
          if (firstItem['return'] == 'true' || firstItem['return'] == true) {
            return StudentModel.fromJson(firstItem);
          } else {
            throw Exception("Invalid student credentials");
          }
        } else {
          throw Exception("Invalid response from server");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<dynamic>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
  }) async {
    try {
      final formData = FormData.fromMap({
        "cdiaryid": cdiaryId,
        "password": password,
        "studentc": "Student",
        "session": session,
        "to": className,
        "section": section,
        "display": "classnot",
      });

      final response = await dio.post(
        "https://www.padhebharat.com/school-notice/school-notice-class-school-cdiary/$schoolCode/",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }
  @override
  Future<List<dynamic>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  }) async {
    try {
      final formData = FormData.fromMap({
        "cdiaryid": cdiaryId,
        "pass": password,
        "session": session,
        "studentc": "Student",
        "profession": "student",
        "month": month,
      });

      final response = await dio.post(
        "https://www.currentdiary.com/school-attendance/api-school-attendance-api/$schoolCode/",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }
}
