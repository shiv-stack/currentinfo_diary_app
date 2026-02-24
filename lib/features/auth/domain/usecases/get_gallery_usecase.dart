import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/gallery_model.dart';
import '../repositories/auth_repository.dart';

class GetGalleryUseCase {
  final AuthRepository repository;

  GetGalleryUseCase(this.repository);

  Future<Either<Failure, List<GalleryModel>>> call(String code) async {
    return await repository.getGallery(code);
  }
}
