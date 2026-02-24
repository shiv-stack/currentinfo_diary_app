import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/gallery_model.dart';
import '../../data/models/school_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, SchoolModel>> getSchoolInfo(String code);
  Future<Either<Failure, List<GalleryModel>>> getGallery(String code);
}
