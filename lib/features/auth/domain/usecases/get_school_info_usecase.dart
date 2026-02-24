import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/school_model.dart';

class GetSchoolInfoUseCase {
  final AuthRepository repository;

  GetSchoolInfoUseCase(this.repository);

  Future<Either<Failure, SchoolModel>> call(String code) async {
    return await repository.getSchoolInfo(code);
  }
}
