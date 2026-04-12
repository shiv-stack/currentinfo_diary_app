import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Staff>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final staff = await remoteDataSource.login(
        schoolCode: schoolCode,
        name: name,
        uniqueCode: uniqueCode,
      );
      return Right(staff);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
