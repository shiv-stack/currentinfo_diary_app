import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendQueryUseCase {
  final AuthRepository repository;

  SendQueryUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String schoolCode,
    required String title,
    required String name,
    required String mobile,
    required String message,
  }) async {
    return await repository.sendQuery(
      schoolCode: schoolCode,
      title: title,
      name: name,
      mobile: mobile,
      message: message,
    );
  }
}
