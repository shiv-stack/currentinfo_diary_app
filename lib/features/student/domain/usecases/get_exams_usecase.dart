import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';
import '../../data/models/exam_model.dart';

class GetExamsUseCase {
  final StudentRepository repository;

  GetExamsUseCase(this.repository);

  Future<Either<Failure, List<ExamModel>>> call({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
  }) async {
    return await repository.getExams(
      schoolCode: schoolCode,
      studentId: studentId,
      password: password,
      session: session,
    );
  }
}
