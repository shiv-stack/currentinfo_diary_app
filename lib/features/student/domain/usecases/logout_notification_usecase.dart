import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class LogoutNotificationUseCase {
  final StudentRepository repository;

  LogoutNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    return await repository.logoutNotification(
      schoolCode: schoolCode,
      name: name,
      uniqueCode: uniqueCode,
    );
  }
}
