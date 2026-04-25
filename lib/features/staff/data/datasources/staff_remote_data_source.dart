import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/staff_model.dart';
import '../../../student/data/models/student_model.dart';
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

  Future<String> updateStudentRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
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
  Future<String> updateStudentRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  }) async {
    try {
      String sanitize(String? val) {
        if (val == null ||
            val.trim().isEmpty ||
            val.trim().toLowerCase() == 'null' ||
            val.trim().toLowerCase() == 'not provided' ||
            val.trim().toLowerCase() == 'not provid') {
          return 'NA';
        }
        return val.trim();
      }

      String sanitizeSection(String? val) {
        if (val == null ||
            val.trim().isEmpty ||
            val.trim().toLowerCase() == 'null' ||
            val.trim().toLowerCase() == 'not applicable') {
          return 'NA';
        }
        return val.trim();
      }

      final formData = FormData.fromMap({
        'cdiaryid': fields['cdiaryid'] ?? '',
        'modify': 'modify',
        'name': fields['name']?.trim() ?? '',
        'transport': fields['transport'] ?? 'NA',
        'lastclass': sanitize(fields['lastclass']),
        'email': sanitize(fields['email']),
        'tcissued': fields['tcissued'] ?? 'No',
        'tcissueddate': sanitize(fields['tcissueddate']),
        'pen_number': sanitize(fields['pen_number']),
        'nationality': sanitize(fields['nationality']),
        'nccscout': fields['nccscout'] ?? 'No',
        'rollno': sanitize(fields['rollno']),
        'registration': sanitize(fields['registration']),
        'schoolhouse': sanitize(fields['schoolhouse']),
        'busno': sanitize(fields['busno']),
        'unique': fields['password']?.trim() ?? '',
        'login': staffLogin,
        'pass': staffPass,
        'staffc': staffClass,
        'newname': fields['name']?.trim() ?? '',
        'class_detail': sanitize(fields['class']),
        'section': sanitizeSection(fields['section']),
        'doa': fields['doa'] ?? 'NA',
        'religion': sanitize(fields['religion']),
        'oldnewadmission': fields['oldnewadmission'] ?? 'Old',
        'message': fields['message'] ?? 'NA',
        'secmob': sanitize(fields['alternatenumber']),
        'adhar': sanitize(fields['adhar']),
        'srnumber': sanitize(fields['srnumber']),
        'family_id': sanitize(fields['family_id']),
        'enroll': sanitize(fields['enroll']),
        'dob': sanitize(fields['dob']),
        'mobile': sanitize(fields['mobile']),
        'father': sanitize(fields['father']),
        'rfid': sanitize(fields['rfid']),
        'height': sanitize(fields['height']),
        'weight': sanitize(fields['weight']),
        'bloodgroup': sanitize(fields['bloodgroup']),
        'mother': sanitize(fields['mother']),
        'address': sanitize(fields['address']),
        'lastschool': sanitize(fields['lastschool']),
        'guardian': sanitize(fields['guardian']),
        'inschool': fields['inschool'] ?? 'Yes',
        'gender': fields['gender'] ?? 'NA',
        'rte': fields['rte'] ?? 'No',
        'category': sanitize(fields['category']),
        'profession': sanitize(fields['profession']),
      });

      final response = await dio.post(
        AppUrls.updateStudentRecord(schoolCode),
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        return response.data?.toString() ?? 'Record updated successfully';
      }
      throw Exception('Failed to update record: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) {
        return e.response?.data?.toString() ?? 'Record updated successfully';
      }
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Connection Error',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
