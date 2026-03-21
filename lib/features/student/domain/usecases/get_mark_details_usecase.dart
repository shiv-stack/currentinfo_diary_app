import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';
import '../../data/models/mark_detail_model.dart';

class GetMarkDetailsUseCase {
  final StudentRepository repository;

  GetMarkDetailsUseCase(this.repository);

  Future<Either<Failure, List<MarkDetailModel>>> call({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
    required String marksClass,
    required String marksYear,
    required String marksExam,
  }) async {
    return await repository.getMarkDetails(
      schoolCode: schoolCode,
      studentId: studentId,
      password: password,
      session: session,
      marksClass: marksClass,
      marksYear: marksYear,
      marksExam: marksExam,
    );
  }
}
