import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/student_model.dart';
import '../models/leave_model.dart';

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

  Future<List<dynamic>> getAssignments({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
    required String day,
    required String studentClass,
    required String section,
    required String showhw,
  });

  Future<List<dynamic>> getFees({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String studentFeeSoftware,
  });

  Future<List<LeaveModel>> getLeaves({
    required String schoolCode,
    required String studentId,
    required String password,
  });

  Future<String> applyLeave({
    required String schoolCode,
    required String studentId,
    required String password,
    required String studentName,
    required String studentClass,
    required String admissionRollNo,
    required String session,
    required String fromDate,
    required String toDate,
    required String reason,
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
        AppUrls.getClassNotice(schoolCode),
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
        AppUrls.getAttendance(schoolCode),
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
  Future<List<dynamic>> getAssignments({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
    required String day,
    required String studentClass,
    required String section,
    required String showhw,
  }) async {
    try {
      final String StringSection;
      final String s = section.toLowerCase().trim();
      if (s == "np" ||
          s == "na" ||
          s == "not provided" ||
          s == "not provid" ||
          s == "" ||
          s == "no" ||
          s == "not applicable") {
        StringSection = "";
      } else {
        StringSection = section;
      }

      final formData = FormData.fromMap({
        'cdiaryid': cdiaryId,
        'password': password,
        'month': month,
        'day': day,
        'studentc': 'Student',
        'showhw': showhw,
        'session': session,
        'class': studentClass,
        'section': StringSection,
      });

      final response = await dio.post(
        AppUrls.getHomework(schoolCode),
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
  Future<List<dynamic>> getFees({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String studentFeeSoftware,
  }) async {
    try {
      final formData = FormData.fromMap({
        'password': password,
        'studentc': 'student',
        'cdiaryid': cdiaryId,
        'session': session,
        'studentfeesoftware': studentFeeSoftware,
        'studentwisefeereceipt': 'Yes',
      });

      final response = await dio.post(
        AppUrls.getFees(schoolCode),
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
  Future<List<LeaveModel>> getLeaves({
    required String schoolCode,
    required String studentId,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'task': 'leaveapply',
        'modify': 'show',
        'login': studentId,
        'password': password,
        'studentc': 'Student',
        'teacherid': studentId,
      });

      final response = await dio.post(
        AppUrls.getMultitask(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> dataList = [];

        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is String && rawData.trim().isNotEmpty) {
          try {
            final dynamic decoded = jsonDecode(rawData.trim());
            if (decoded is List) {
              dataList = decoded;
            }
          } catch (e) {
            // Not a JSON list, return empty
            return [];
          }
        }

        return dataList.map((json) => LeaveModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<String> applyLeave({
    required String schoolCode,
    required String studentId,
    required String password,
    required String studentName,
    required String studentClass,
    required String admissionRollNo,
    required String session,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    try {
      final formData = FormData.fromMap({
        'task': 'leaveapply',
        'login': studentId,
        'password': password,
        'studentc': 'Student',
        'modify': 'create',
        'teacherid': studentId,
        'teachername': studentName,
        'teacherclass': studentClass,
        'admissionrollno': admissionRollNo,
        'sessionvalue': session,
        'transportvalue': 'NA',
        'fromdate': fromDate,
        'todate': toDate,
        'halfdayvalue': 'NA',
        'halfdayvalue2': 'NA',
        'reasonsforleave': reason,
      });

      final response = await dio.post(
        AppUrls.getMultitask(schoolCode),
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        return response.data.toString().trim();
      }
      throw Exception("Server Error: ${response.statusCode}");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }
}
