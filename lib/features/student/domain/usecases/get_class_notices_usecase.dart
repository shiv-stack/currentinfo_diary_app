import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class GetClassNoticesUseCase {
  final StudentRepository repository;

  GetClassNoticesUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
    String display = "classnot",
  }) {
    return repository.getClassNotices(
      schoolCode: schoolCode,
      cdiaryId: cdiaryId,
      password: password,
      session: session,
      className: className,
      section: section,
      display: display,
    );
  }
}
