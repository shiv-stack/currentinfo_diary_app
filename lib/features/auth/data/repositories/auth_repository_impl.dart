import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/gallery_model.dart';
import '../models/school_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SchoolModel>> getSchoolInfo(String code) async {
    try {
      final result = await remoteDataSource.getSchoolInfo(code);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GalleryModel>>> getGallery(String code) async {
    try {
      final result = await remoteDataSource.getGallery(code);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
