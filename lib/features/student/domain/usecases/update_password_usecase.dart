import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class UpdatePasswordUseCase {
  final StudentRepository repository;

  UpdatePasswordUseCase({required this.repository});

  Future<Either<Failure, String>> call({
    required String schoolCode,
    required String studentId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await repository.updatePassword(
      schoolCode: schoolCode,
      studentId: studentId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
