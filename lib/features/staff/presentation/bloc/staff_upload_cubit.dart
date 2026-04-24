import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/staff_upload_data_usecase.dart';
import 'staff_upload_state.dart';

class StaffUploadCubit extends Cubit<StaffUploadState> {
  final StaffUploadDataUseCase uploadDataUseCase;

  StaffUploadCubit({required this.uploadDataUseCase}) : super(StaffUploadInitial());

  Future<void> uploadData({
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
    required String featureTitle,
    String? filePath,
  }) async {
    emit(StaffUploadLoading());

    final result = await uploadDataUseCase(
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
      featureTitle: featureTitle,
      filePath: filePath,
    );

    result.fold(
      (failure) => emit(StaffUploadFailure(failure.message)),
      (message) => emit(StaffUploadSuccess(message)),
    );
  }
}
