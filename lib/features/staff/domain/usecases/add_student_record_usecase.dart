import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_repository.dart';

class AddStudentRecordUseCase {
  final StaffRepository repository;

  AddStudentRecordUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  }) {
    return repository.addStudentRecord(
      schoolCode: schoolCode,
      staffLogin: staffLogin,
      staffPass: staffPass,
      staffClass: staffClass,
      fields: fields,
    );
  }
}
