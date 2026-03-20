import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StudentModel>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final student = await remoteDataSource.login(
        schoolCode: schoolCode,
        name: name,
        uniqueCode: uniqueCode,
      );
      return Right(student);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
  }) async {
    try {
      final notices = await remoteDataSource.getClassNotices(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        className: className,
        section: section,
      );
      return Right(notices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  }) async {
    try {
      final attendance = await remoteDataSource.getAttendance(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        month: month,
      );
      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
