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
}
