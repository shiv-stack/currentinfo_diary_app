import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';
import '../../data/models/student_model.dart';

class StudentLoginUseCase {
  final StudentRepository repository;

  StudentLoginUseCase(this.repository);

  Future<Either<Failure, StudentModel>> call({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    return await repository.login(
      schoolCode: schoolCode,
      name: name,
      uniqueCode: uniqueCode,
    );
  }
}
