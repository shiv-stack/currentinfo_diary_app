import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class GetAssignmentsUseCase {
  final StudentRepository repository;

  GetAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
    required String day,
    required String studentClass,
    required String section,
    required String showhw,
  }) async {
    return await repository.getAssignments(
      schoolCode: schoolCode,
      cdiaryId: cdiaryId,
      password: password,
      session: session,
      month: month,
      day: day,
      studentClass: studentClass,
      section: section,
      showhw: showhw,
    );
  }
}
