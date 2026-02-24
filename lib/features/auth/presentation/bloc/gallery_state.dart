import 'package:equatable/equatable.dart';
import '../../data/models/gallery_model.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<GalleryModel> images;

  const GalleryLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class GalleryError extends GalleryState {
  final String message;

  const GalleryError(this.message);

  @override
  List<Object?> get props => [message];
}
