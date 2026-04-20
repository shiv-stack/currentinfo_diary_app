import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/staff_login_usecase.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffLoginUseCase staffLoginUseCase;
  final AuthLocalDataSource authLocalDataSource;

  StaffBloc({
    required this.staffLoginUseCase,
    required this.authLocalDataSource,
  }) : super(StaffInitial()) {
    on<StaffLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    StaffLoginSubmitted event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());

    final result = await staffLoginUseCase(
      schoolCode: event.schoolCode,
      name: event.name,
      uniqueCode: event.uniqueCode,
    );

    await result.fold(
      (failure) async => emit(StaffLoginFailure(failure.message)),
      (staff) async {
        // Clear any existing student session to prevent conflicts
        await authLocalDataSource.clearActiveStudentSession();
        
        // Persist staff session
        await authLocalDataSource.cacheActiveStaffCredentials(
          event.name,
          event.uniqueCode,
        );
        if (staff.cdiaryId != null && staff.cdiaryId!.isNotEmpty) {
          await authLocalDataSource.cacheStaffCdiaryId(staff.cdiaryId!);
        }
        emit(StaffLoginSuccess(staff));
      },
    );
  }
}
