import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff.dart';
import '../repositories/staff_repository.dart';

class StaffLoginUseCase {
  final StaffRepository repository;

  StaffLoginUseCase(this.repository);

  Future<Either<Failure, Staff>> call({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    return await repository.login(
      schoolCode: schoolCode,
      name: name,
      uniqueCode: uniqueCode,
    );
  }
}
