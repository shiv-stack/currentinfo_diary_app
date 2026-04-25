import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff.dart';
import '../../../student/data/models/student_model.dart';

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
    required String featureTitle,
    String? filePath,
  });

  Future<Either<Failure, List<StudentModel>>> getStudentRecord({
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

  Future<Either<Failure, String>> updateStudentRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  });

  Future<Either<Failure, String>> addStudentRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  });
}
