import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';
import '../../data/models/leave_model.dart';

class GetLeavesUseCase {
  final StudentRepository repository;

  GetLeavesUseCase(this.repository);

  Future<Either<Failure, List<LeaveModel>>> call({
    required String schoolCode,
    required String studentId,
    required String password,
  }) async {
    return await repository.getLeaves(
      schoolCode: schoolCode,
      studentId: studentId,
      password: password,
    );
  }
}
