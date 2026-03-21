import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class GetMessagesUseCase {
  final StudentRepository repository;

  GetMessagesUseCase({required this.repository});

  Future<Either<Failure, List<dynamic>>> call({
    required String schoolCode,
    required String studentId,
    required String password,
  }) async {
    return await repository.getMessages(
      schoolCode: schoolCode,
      studentId: studentId,
      password: password,
    );
  }
}
