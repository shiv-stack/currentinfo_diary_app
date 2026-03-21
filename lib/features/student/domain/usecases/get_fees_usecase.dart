import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class GetFeesUseCase {
  final StudentRepository repository;

  GetFeesUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String studentFeeSoftware,
  }) async {
    return await repository.getFees(
      schoolCode: schoolCode,
      cdiaryId: cdiaryId,
      password: password,
      session: session,
      studentFeeSoftware: studentFeeSoftware,
    );
  }
}
