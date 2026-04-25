import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_student_record_usecase.dart';
import '../../domain/usecases/add_student_record_usecase.dart';
import 'user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> {
  final UpdateStudentRecordUseCase updateStudentRecordUseCase;
  final AddStudentRecordUseCase addStudentRecordUseCase;

  UserDetailCubit({
    required this.updateStudentRecordUseCase,
    required this.addStudentRecordUseCase,
  }) : super(UserDetailInitial());

  Future<void> updateRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  }) async {
    emit(UserDetailLoading());

    // Map gender before sending to usecase
    final mutableFields = Map<String, String>.from(fields);
    final gender = mutableFields['gender']?.toLowerCase() ?? '';
    if (gender == 'male' || gender == 'm') {
      mutableFields['gender'] = 'M';
    } else if (gender == 'female' || gender == 'f') {
      mutableFields['gender'] = 'F';
    }

    final result = await updateStudentRecordUseCase(
      schoolCode: schoolCode,
      staffLogin: staffLogin,
      staffPass: staffPass,
      staffClass: staffClass,
      fields: mutableFields,
    );

    result.fold(
      (failure) => emit(UserDetailUpdateFailure(failure.message)),
      (success) => emit(UserDetailUpdateSuccess(success)),
    );
  }

  Future<void> addRecord({
    required String schoolCode,
    required String staffLogin,
    required String staffPass,
    required String staffClass,
    required Map<String, String> fields,
  }) async {
    emit(UserDetailLoading());

    final result = await addStudentRecordUseCase(
      schoolCode: schoolCode,
      staffLogin: staffLogin,
      staffPass: staffPass,
      staffClass: staffClass,
      fields: fields,
    );

    result.fold(
      (failure) => emit(UserDetailUpdateFailure(failure.message)),
      (success) => emit(UserDetailUpdateSuccess(success)),
    );
  }
}
