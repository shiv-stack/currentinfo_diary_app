import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class GetAttendanceUseCase {
  final StudentRepository repository;

  GetAttendanceUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  }) {
    return repository.getAttendance(
      schoolCode: schoolCode,
      cdiaryId: cdiaryId,
      password: password,
      session: session,
      month: month,
    );
  }
}
