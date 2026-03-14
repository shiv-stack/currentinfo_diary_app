import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/student_model.dart';

abstract class StudentRepository {
  Future<Either<Failure, StudentModel>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });
}
