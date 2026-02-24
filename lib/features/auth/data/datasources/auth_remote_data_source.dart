import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/gallery_model.dart';
import '../models/school_model.dart';

abstract class AuthRemoteDataSource {
  Future<SchoolModel> getSchoolInfo(String code);
  Future<List<GalleryModel>> getGallery(String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<SchoolModel> getSchoolInfo(String code) async {
    try {
      final response = await dio.get(AppUrls.getSchoolInfo(code));
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }

        if (data is Map<String, dynamic>) {
          return SchoolModel.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          return SchoolModel.fromJson(data[0]);
        }
        throw Exception("Invalid response format");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }

  @override
  Future<List<GalleryModel>> getGallery(String code) async {
    try {
      final response = await dio.get(AppUrls.getGallery(code));
      if (response.statusCode == 200) {
        var data = response.data;

        // Handle case where server returns a JSON string instead of a parsed object
        if (data is String) {
          data = jsonDecode(data);
        }

        if (data is List) {
          return data
              .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Connection Error");
    }
  }
}
