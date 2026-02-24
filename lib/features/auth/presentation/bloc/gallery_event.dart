import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

class FetchGallery extends GalleryEvent {
  final String code;

  const FetchGallery(this.code);

  @override
  List<Object?> get props => [code];
}
