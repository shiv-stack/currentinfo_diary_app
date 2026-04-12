import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/staff_model.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/push_notification_service.dart';

abstract class StaffRemoteDataSource {
  Future<StaffModel> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;

  StaffRemoteDataSourceImpl({required this.dio});

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
            name: staff.name,
            designation: staff.designation,
            dob: staff.dob,
            contactNumber: staff.contactNumber,
            cdiaryId: staff.cdiaryId,
            schoolName: staff.schoolName,
            address: staff.address,
            email: staff.email,
            schoolCode: schoolCode,
            password: staff.password,
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
}
