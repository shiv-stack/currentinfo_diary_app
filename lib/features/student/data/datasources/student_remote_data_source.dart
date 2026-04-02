import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/student_model.dart';
import '../models/leave_model.dart';
import '../models/exam_model.dart';
import '../models/mark_detail_model.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/push_notification_service.dart';

abstract class StudentRemoteDataSource {
  Future<StudentModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
    String status = "Subscribe",
  });

  Future<void> logoutNotification({
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
    String display = "classnot",
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

  Future<String> updatePassword({
    required String schoolCode,
    required String studentId,
    required String currentPassword,
    required String newPassword,
  });

  Future<List<dynamic>> getMessages({
    required String schoolCode,
    required String studentId,
    required String password,
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
    String status = "Subscribe",
  }) async {
    try {
      final pushNotificationService = sl<PushNotificationService>();
      final String? deviceToken = await pushNotificationService.getToken();

      final formData = FormData.fromMap({
        'Name': name,
        'Profession': 'Student',
        'studentc': 'Student',
        'Unique_Code': uniqueCode,
        'token': deviceToken ?? "",
        'appname': 'iOS',
        'status': status,
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
          final student = StudentModel.fromJson(data[0]);
          // debugPrint('Student == > ${student.toJson()}');
          // Check if cdiaryId is present, if not, it's an invalid login
          if (student.cdiaryId == null || student.cdiaryId!.isEmpty) {
            throw Exception("Invalid credentials or student not found");
          }

          // Inject schoolCode manually as it's not in the student object from API usually
          return StudentModel(
            studentImage: student.studentImage,
            thoughtTitle: student.thoughtTitle,
            thoughtMessage: student.thoughtMessage,
            name: student.name,
            className: student.className,
            dob: student.dob,
            contactNumber: student.contactNumber,
            cdiaryId: student.cdiaryId,
            section: student.section,
            session: student.session,
            schoolName: student.schoolName,
            address: student.address,
            email: student.email,
            fatherName: student.fatherName,
            motherName: student.motherName,
            schoolCode: schoolCode,
            enrollNumber: student.enrollNumber,
            password: student.password,
            doa: student.doa,
          );
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
  Future<void> logoutNotification({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final pushNotificationService = sl<PushNotificationService>();
      final String? deviceToken = await pushNotificationService.getToken();

      final formData = FormData.fromMap({
        'Name': name,
        'Profession': 'Student',
        'studentc': 'Student',
        'Unique_Code': uniqueCode,
        'token': deviceToken ?? "",
        'appname': 'iOS',
        'status': 'logout',
      });

      await dio.post(AppUrls.studentLogin(schoolCode), data: formData);
    } catch (e) {
      // Just log and continue, logout should not fail due to notification sync
      debugPrint("Logout notification sync failed: $e");
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
    String display = "classnot",
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
        'display': display,
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
        'day': showhw == 'Monthwise' ? '' : day,
        'studentc': 'Student',
        'class': studentClass,
        'section': section,
        'showhw': showhw,
      });

      final response = await dio.post(
        AppUrls.getAssignments(schoolCode),
        data: formData,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
          },
        ),
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
        final List<dynamic> rawData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Filter out empty maps or objects with no actual content
        return rawData.where((item) {
          if (item is Map) {
            return item.isNotEmpty &&
                item.values.any(
                  (v) => v != null && v.toString().trim().isNotEmpty,
                );
          }
          return item != null;
        }).toList();
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
            debugPrint("Exam Decode Error: $e");
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
        'modify': '',
        'year': marksYear,
        'examdesc': marksExam,
        'classdetail': marksClass,
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
            debugPrint("Mark Details Decode Error: $e");
          }
        }

        if (dataList.isNotEmpty && dataList[0] is Map) {
          final Map<String, dynamic> firstObj =
              dataList[0] as Map<String, dynamic>;
          final List<MarkDetailModel> marks = [];

          final String? globalRoll = firstObj['rollno']?.toString();
          final String? globalAttendance = firstObj['attendance']?.toString();
          final String? globalTotalAttendance = firstObj['totalattendance']
              ?.toString();
          final String? globalEnroll = firstObj['enrollment_number']
              ?.toString();
          final String? rollNo =
              (globalRoll == null || globalRoll.trim().toLowerCase() == "na")
              ? null
              : globalRoll.trim();
          final String? attendance =
              (globalAttendance == null ||
                  globalAttendance.trim().toLowerCase() == "na")
              ? null
              : globalAttendance.trim();
          final String? totalAttendance =
              (globalTotalAttendance == null ||
                  globalTotalAttendance.trim().toLowerCase() == "na")
              ? null
              : globalTotalAttendance.trim();
          final String? enrollmentNumber =
              (globalEnroll == null ||
                  globalEnroll.trim().toLowerCase() == "na")
              ? null
              : globalEnroll.trim();

          // Parse main subjects (sub1 - sub15)
          for (int i = 1; i <= 15; i++) {
            final String? sub = firstObj['sub$i']?.toString();
            if (sub != null &&
                sub.isNotEmpty &&
                sub.trim().toLowerCase() != "na") {
              final String? grade = firstObj['grade$i']?.toString();
              final String? marksVal = firstObj['marks$i']?.toString();
              final String? limitVal = firstObj['limitmark$i']?.toString();
              marks.add(
                MarkDetailModel(
                  subject: sub.trim(),
                  marksObtained:
                      (marksVal == null ||
                          marksVal.trim().toLowerCase() == "na")
                      ? null
                      : marksVal.trim(),
                  maxMarks:
                      (limitVal == null ||
                          limitVal.trim().toLowerCase() == "na")
                      ? null
                      : limitVal.trim(),
                  grade: (grade == null || grade.trim().toLowerCase() == "na")
                      ? null
                      : grade.trim(),
                  rollNo: rollNo,
                  attendance: attendance,
                  totalAttendance: totalAttendance,
                  enrollmentNumber: enrollmentNumber,
                ),
              );
            }
          }

          // Parse Co-Scholastic Aspects (gradename21 - 24)
          for (int i = 21; i <= 24; i++) {
            final String? sub = firstObj['gradename$i']?.toString();
            if (sub != null &&
                sub.isNotEmpty &&
                sub.trim().toLowerCase() != "na") {
              final String? grade = firstObj['grade$i']?.toString();
              marks.add(
                MarkDetailModel(
                  subject: sub.trim(),
                  grade: (grade == null || grade.trim().toLowerCase() == "na")
                      ? null
                      : grade.trim(),
                  rollNo: rollNo,
                  attendance: attendance,
                  totalAttendance: totalAttendance,
                  enrollmentNumber: enrollmentNumber,
                ),
              );
            }
          }

          // Parse Extra Scholastic Aspects (gradename31 - 35)
          for (int i = 31; i <= 35; i++) {
            final String? sub = firstObj['gradename$i']?.toString();
            if (sub != null &&
                sub.isNotEmpty &&
                sub.trim().toLowerCase() != "na") {
              final String? grade = firstObj['grade$i']?.toString();
              marks.add(
                MarkDetailModel(
                  subject: sub.trim(),
                  grade: (grade == null || grade.trim().toLowerCase() == "na")
                      ? null
                      : grade.trim(),
                  rollNo: rollNo,
                  attendance: attendance,
                  totalAttendance: totalAttendance,
                  enrollmentNumber: enrollmentNumber,
                ),
              );
            }
          }

          if (marks.isNotEmpty) return marks;
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

  @override
  Future<String> updatePassword({
    required String schoolCode,
    required String studentId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final formData = FormData.fromMap({
        'cdiaryid': studentId,
        'unique': newPassword,
        'modify': 'modify',
        'login': 'student_modify_pass',
        'pass': currentPassword,
      });

      final response = await dio.post(
        AppUrls.updatePassword(schoolCode),
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

  @override
  Future<List<dynamic>> getMessages({
    required String schoolCode,
    required String studentId,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'task': 'onetoonemessage',
        'modify': 'show',
        'uniqueshow': '',
        'stuid': studentId,
        'password': password,
        'studentc': 'Student',
      });

      final response = await dio.post(
        AppUrls.getMessages(schoolCode),
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.data);
        return data;
      } else {
        throw Exception(
          "Failed to load messages (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
