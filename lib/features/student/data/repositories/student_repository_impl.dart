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
}
