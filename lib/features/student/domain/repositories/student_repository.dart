import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/student_model.dart';

abstract class StudentRepository {
  Future<Either<Failure, StudentModel>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<Either<Failure, List<dynamic>>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
  });

  Future<Either<Failure, List<dynamic>>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  });
}
