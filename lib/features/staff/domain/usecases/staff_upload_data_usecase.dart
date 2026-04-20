import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_repository.dart';

class StaffUploadDataUseCase {
  final StaffRepository repository;

  StaffUploadDataUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String schoolCode,
    required String login,
    required String password,
    required String staffClass,
    required String title,
    required String description,
    required String className,
    required String section,
    required String session,
    required String uploadDetails,
    String? filePath,
  }) async {
    return await repository.uploadData(
      schoolCode: schoolCode,
      login: login,
      password: password,
      staffClass: staffClass,
      title: title,
      description: description,
      className: className,
      section: section,
      session: session,
      uploadDetails: uploadDetails,
      filePath: filePath,
    );
  }
}
