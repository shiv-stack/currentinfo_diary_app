import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff.dart';

abstract class StaffRepository {
  Future<Either<Failure, Staff>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<Either<Failure, String>> uploadData({
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
    String? filePath,
  });
}
