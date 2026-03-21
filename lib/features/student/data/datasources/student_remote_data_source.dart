import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/student_model.dart';
import '../models/leave_model.dart';
import '../models/exam_model.dart';
import '../models/mark_detail_model.dart';

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

  Future<List<ExamModel>> getExams({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
  });

  Future<List<MarkDetailModel>> getMarkDetails({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
    required String marksClass,
    required String marksYear,
    required String marksExam,
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
        final dynamic rawData = response.data;
        List<dynamic> data = [];

        if (rawData is List) {
          data = rawData;
        } else if (rawData is String && rawData.trim().isNotEmpty) {
          data = jsonDecode(rawData);
        }

        if (data.isNotEmpty) {
          return StudentModel.fromJson(data[0]);
        }
      }
      throw Exception("Invalid credentials or student not found");
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception("Server is busy, please try again later");
      }
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
      final sectionValue =
          (section.toUpperCase() == "NA" ||
              section.toUpperCase() == "NP" ||
              section.toLowerCase() == "not provided")
          ? "NA"
          : section;

      final formData = FormData.fromMap({
        'cdiaryid': cdiaryId,
        'password': password,
        'studentc': 'Student',
        'session': session,
        'to': className,
        'section': sectionValue,
        'display': 'classnot',
      });

      final response = await dio.post(
        AppUrls.getClassNotices(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data is String
            ? jsonDecode(response.data)
            : response.data;
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
      final monthValue = (month.toLowerCase() == "complete attendance")
          ? ""
          : month;

      final formData = FormData.fromMap({
        'cdiaryid': cdiaryId,
        'pass': password,
        'session': session,
        'studentc': 'Student',
        'profession': 'student',
        'month': monthValue,
      });

      final response = await dio.post(
        AppUrls.getAttendance(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data is String
            ? jsonDecode(response.data)
            : response.data;
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
      final formData = FormData.fromMap({
        'cdiaryid': cdiaryId,
        'password': password,
        'session': session,
        'month': month,
        'day': day,
        'class': studentClass,
        'section': section,
        'showhw': showhw,
      });

      final response = await dio.post(
        AppUrls.getAssignments(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data is String
            ? jsonDecode(response.data)
            : response.data;
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
        'cdiaryid': cdiaryId,
        'password': password,
        'studentc': 'student',
        'session': session,
        'studentfeesoftware': studentFeeSoftware,
        'studentwisefeereceipt': 'Yes',
      });

      final response = await dio.post(
        AppUrls.getFees(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data is String
            ? jsonDecode(response.data)
            : response.data;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<ExamModel>> getExams({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
  }) async {
    try {
      final formData = FormData.fromMap({
        'marksid': studentId,
        'password': password,
        'studentc': 'Student',
        'modify': 'shows_exam',
        'session': session,
      });

      final response = await dio.post(
        AppUrls.getMarks(schoolCode),
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
            print("Exam Decode Error: $e");
          }
        }

        return dataList
            .map((json) => ExamModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception("Server is busy, please try again later");
      }
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<MarkDetailModel>> getMarkDetails({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
    required String marksClass,
    required String marksYear,
    required String marksExam,
  }) async {
    try {
      final formData = FormData.fromMap({
        'marksid': studentId,
        'password': password,
        'studentc': 'Student',
        'modify': 'shows',
        'session': session,
        'marksclass': marksClass,
        'marksyear': marksYear,
        'marksexam': marksExam,
      });

      final response = await dio.post(
        AppUrls.getMarks(schoolCode),
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
            print("Mark Details Decode Error: $e");
          }
        }

        return dataList
            .map(
              (json) => MarkDetailModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception("Server is busy, please try again later");
      }
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
            return [];
          }
        }

        return dataList
            .map((json) => LeaveModel.fromJson(json as Map<String, dynamic>))
            .toList();
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
        'modify': 'create',
        'login': studentId,
        'password': password,
        'studentc': 'Student',
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
