import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/gallery_model.dart';
import '../../data/models/school_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, SchoolModel>> getSchoolInfo(String code);
  Future<Either<Failure, List<GalleryModel>>> getGallery(String code);
  Future<Either<Failure, void>> sendQuery({
    required String schoolCode,
    required String title,
    required String name,
    required String mobile,
    required String message,
  });
}
