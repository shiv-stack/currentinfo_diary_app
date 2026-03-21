import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class ApplyLeaveUseCase {
  final StudentRepository repository;

  ApplyLeaveUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String schoolCode,
    required String studentId,
    required String password,
    required String studentName,
    required String studentClass,
    required String admissionRollNo,
    required String session,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    return await repository.applyLeave(
      schoolCode: schoolCode,
      studentId: studentId,
      password: password,
      studentName: studentName,
      studentClass: studentClass,
      admissionRollNo: admissionRollNo,
      session: session,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
    );
  }
}
