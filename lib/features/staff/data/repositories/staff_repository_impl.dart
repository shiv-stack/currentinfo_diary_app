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

  @override
  Future<Either<Failure, String>> uploadData({
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
    try {
      final result = await remoteDataSource.uploadData(
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
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
