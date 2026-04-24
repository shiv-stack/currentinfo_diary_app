import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/staff_login_usecase.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../data/datasources/staff_local_data_source.dart';
import '../../domain/entities/saved_staff.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffLoginUseCase staffLoginUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final StaffLocalDataSource staffLocalDataSource;

  StaffBloc({
    required this.staffLoginUseCase,
    required this.authLocalDataSource,
    required this.staffLocalDataSource,
  }) : super(StaffInitial()) {
    on<StaffLoginSubmitted>(_onLoginSubmitted);
    on<GetSavedStaff>(_onGetSavedStaff);
    on<DeleteSavedStaff>(_onDeleteSavedStaff);
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

        // Save to local DB for "Switch Account" feature
        await staffLocalDataSource.saveStaff(
          SavedStaff(
            schoolCode: event.schoolCode,
            name: event.name,
            uniqueCode: event.uniqueCode,
            profileImage: staff.staffImage,
            assignClass: staff.assignClass,
          ),
        );

        emit(StaffLoginSuccess(staff));
      },
    );
  }

  Future<void> _onGetSavedStaff(
    GetSavedStaff event,
    Emitter<StaffState> emit,
  ) async {
    final savedStaff = await staffLocalDataSource.getSavedStaff();
    emit(SavedStaffLoaded(savedStaff));
  }

  Future<void> _onDeleteSavedStaff(
    DeleteSavedStaff event,
    Emitter<StaffState> emit,
  ) async {
    await staffLocalDataSource.removeStaff(event.uniqueCode);
    add(GetSavedStaff());
  }
}
