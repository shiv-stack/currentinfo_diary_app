import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/staff_model.dart';
import '../../../student/data/models/student_model.dart';
import '../models/fee_report_model.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/push_notification_service.dart';

abstract class StaffRemoteDataSource {
  Future<StaffModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<String> uploadData({
    required String schoolCode,
    required String login,
    required String password,
    required String staffClass,
    required String title,
    required String description,
    required String className,
    required String section,
    required String session,
    required String uploadDetails,
    required String featureTitle,
    String? filePath,
  });

  Future<List<StudentModel>> getStudentRecord({
    required String schoolCode,
    required String teaname,
    required String tpass,
    required String tclass,
    required String inschool,
    required String session,
    required String classValue,
    required String profession,
    required String section,
    required String transportstatus,
  });

  Future<List<FeeReportModel>> getFeeReport({
    required String schoolCode,
    required String login,
    required String password,
    required String session,
    required String reportType,
    required String paymentMode,
    required String day,
    required String month,
    required String staffc,
    required String studentFeeSoftware,
  });
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;

  StaffRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> uploadData({
    required String schoolCode,
    required String login,
    required String password,
    required String staffClass,
    required String title,
    required String description,
    required String className,
    required String section,
    required String session,
    required String uploadDetails,
    required String featureTitle,
    String? filePath,
  }) async {
    try {
      final List<String> classNoticeFeatures = [
        "holiday homework",
        "upload notice",
        "datesheet",
        "timetable",
        "syllabus",
        "slaybus",
        "class circular",
        "class notice",
      ];
      final String normalizedTitle = featureTitle.trim().toLowerCase();
      final bool useClassNoticeApi = classNoticeFeatures.contains(
        normalizedTitle,
      );
      final String apiUrl = useClassNoticeApi
          ? AppUrls.getClassNotices(schoolCode)
          : AppUrls.uploadStaffData(schoolCode);

      final Map<String, dynamic> data = {};

      if (useClassNoticeApi) {
        String displayValue = "HolidayHw";
        if (normalizedTitle == "upload notice" ||
            normalizedTitle == "class notice") {
          displayValue = "classnot";
        } else if (normalizedTitle == "datesheet") {
          displayValue = "Datesheet";
        } else if (normalizedTitle == "timetable") {
          displayValue = "Timetable";
        } else if (normalizedTitle == "syllabus" ||
            normalizedTitle == "slaybus") {
          displayValue = "Syllabus";
        } else if (normalizedTitle == "class circular") {
          displayValue =
              "classnot"; // Or another value if specified? Assuming classnot for circulars too.
        }

        data.addAll({
          'login': login,
          'password': password,
          'staffc': staffClass,
          'title': title,
          'desc': description,
          'uploaddetails': login,
          'section':
              (section.isEmpty ||
                  section == "Section" ||
                  section.toLowerCase().contains("not applicable"))
              ? "NA"
              : section,
          'session': session,
          'to': className,
          'as': 'Notification',
          'hs': 'No',
          'display': displayValue,
          'inschool': 'Yes',
        });
      } else {
        data.addAll({
          'login': login,
          'passwo': password,
          'staffc': staffClass,
          'title': title,
          'desc': description,
          'name': login,
          'class': className,
          'sec':
              (section.isEmpty ||
                  section == "Section" ||
                  section.toLowerCase().contains("not applicable"))
              ? "NA"
              : section,
          'hindisms': 'No',
          'sms': 'Notification',
          'uploaddetails': uploadDetails,
          'session': session,
        });
      }

      if (filePath != null && filePath.isNotEmpty) {
        final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
        final typeSplit = mimeType.split('/');
        data['myfile'] = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: MediaType(typeSplit[0], typeSplit[1]),
        );
      }

      final formData = FormData.fromMap(data);

      final response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('message')) {
          return resData['message'].toString();
        }
        return resData.toString();
      }
      throw Exception("Upload failed with status code: ${response.statusCode}");
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) {
        return e.response?.data?.toString() ?? "Upload Successful";
      }
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            "Connection Error during upload",
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<StaffModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final pushNotificationService = sl<PushNotificationService>();
      final String? deviceToken = await pushNotificationService.getToken();

      final formData = FormData.fromMap({
        'name': name,
        'password': uniqueCode,
        'appvalue': schoolCode,
        'appname': 'iOS',
        'token': deviceToken ?? "",
        'list': "",
      });

      final response = await dio.post(
        AppUrls.staffLogin(schoolCode),
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
          final staff = StaffModel.fromJson(data[0]);
          if (staff.cdiaryId == null || staff.cdiaryId!.isEmpty) {
            throw Exception("Invalid credentials or staff member not found");
          }

          return StaffModel(
            staffImage: staff.staffImage,
            name: staff.name ?? name,
            designation: staff.designation,
            dob: staff.dob,
            contactNumber: staff.contactNumber,
            cdiaryId: staff.cdiaryId,
            schoolName: staff.schoolName,
            address: staff.address,
            email: staff.email,
            schoolCode: schoolCode,
            password: uniqueCode,
            feedbackUrl: staff.feedbackUrl,
            attendanceUrl: staff.attendanceUrl,
            controlSms: staff.controlSms,
            month: staff.month,
            behaviourUrl: staff.behaviourUrl,
            checkPlanner: staff.checkPlanner,
            uploadMarks: staff.uploadMarks,
            checkAssignmentUrl: staff.checkAssignmentUrl,
            assignmentUrl: staff.assignmentUrl,
            galleryNewUrlGlide: staff.galleryNewUrlGlide,
            galleryUrl: staff.galleryUrl,
            vts: staff.vts,
            costExpense: staff.costExpense,
            contactSchool: staff.contactSchool,
            returnStatus: staff.returnStatus,
            tokenMainHit: staff.tokenMainHit,
            getPassword: staff.getPassword,
            assignClass: staff.assignClass,
          );
        }
      }
      throw Exception("Invalid credentials or staff member not found");
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception("Server is busy, please try again later");
      }
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<StudentModel>> getStudentRecord({
    required String schoolCode,
    required String teaname,
    required String tpass,
    required String tclass,
    required String inschool,
    required String session,
    required String classValue,
    required String profession,
    required String section,
    required String transportstatus,
  }) async {
    try {
      final List<String> staffProfessions = [
        "Chairman",
        "Teacher",
        "Student",
        "Vice-Principal",
        "Principal",
        "Director",
        "Helper",
        "Accountant",
        "Staff",
        "Driver",
        "Admin",
      ];

      final bool isStaffRole = staffProfessions.any(
        (p) => p.toLowerCase() == classValue.toLowerCase(),
      );

      final String mappedProfession = isStaffRole ? classValue : "Student";
      final String mappedClassValue = (classValue == "Twelfth")
          ? "Twelth"
          : (isStaffRole ? "" : classValue);

      final String mappedSection = (section == "Section") ? "" : section;
      final String mappedInSchool = (inschool == "School Status - Yes")
          ? "Yes"
          : "No";

      var transportstatusValue = (transportstatus.toLowerCase() == "transport")
          ? ""
          : transportstatus;

      final formData = FormData.fromMap({
        'login': teaname,
        'pass': tpass,
        'staffc': tclass,
        'inschool': mappedInSchool,
        'session': session,
        'Class': mappedClassValue,
        'Profession': mappedProfession,
        'section': mappedSection,
        'transportfacility': transportstatusValue,
      });

      final response = await dio.post(
        AppUrls.getStudentRecord(schoolCode),
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

        return data.map((json) => StudentModel.fromJson(json)).toList();
      }
      throw Exception("Failed to fetch student record");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<FeeReportModel>> getFeeReport({
    required String schoolCode,
    required String login,
    required String password,
    required String session,
    required String reportType,
    required String paymentMode,
    required String day,
    required String month,
    required String staffc,
    required String studentFeeSoftware,
  }) async {
    try {
      // EXACT same form-data field names as Postman
      final formData = FormData.fromMap({
        'login': login,
        'password': password,
        'staffc': staffc,
        'date': day,
        'studentfeesoftware': studentFeeSoftware,
        'month': month,
        'session': session,
        'cashchequevalue': paymentMode,
        'reporttype': reportType,
      });

      if (kDebugMode) {
        print('[FEE_REPORT] Request: staffc=$staffc, date=$day, month=$month, type=$reportType');
      }

      if (kDebugMode) {
        print('--- Fee Report API Request Payload ---');
        formData.fields.forEach((field) => print('  ${field.key}: ${field.value}'));
      }

      final response = await dio.post(
        AppUrls.getFees(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        print('--- RAW API RESPONSE (Fee Report) ---');
        print(rawData);

        List<dynamic> dataList = [];
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map) {
          dataList = [rawData];
        } else if (rawData is String && rawData.trim().isNotEmpty) {
          final decoded = jsonDecode(rawData);
          if (decoded is List) {
            dataList = decoded;
          } else if (decoded is Map) {
            dataList = [decoded];
          }
        }

        // Filter out empty maps like [{}] before parsing
        final parsed = dataList
            .where((json) => json is Map && json.isNotEmpty && json.keys.isNotEmpty)
            .map((json) => FeeReportModel.fromJson(json as Map<String, dynamic>))
            .toList();

        print('Parsed Fee List Length: ${parsed.length}');
        if (parsed.isNotEmpty) {
          print('First Parsed Item: ${parsed[0]}');
        }

        return parsed;
      }
      throw Exception("Failed to fetch fee report (Status: ${response.statusCode})");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error during fee report fetch");
    }
  }
}
