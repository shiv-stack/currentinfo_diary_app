import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_gallery_usecase.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetGalleryUseCase getGalleryUseCase;

  GalleryBloc({required this.getGalleryUseCase}) : super(GalleryInitial()) {
    on<FetchGallery>(_onFetchGallery);
  }

  Future<void> _onFetchGallery(
    FetchGallery event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    final result = await getGalleryUseCase(event.code);
    result.fold(
      (failure) => emit(GalleryError(failure.message)),
      (images) => emit(GalleryLoaded(images)),
    );
  }
}
