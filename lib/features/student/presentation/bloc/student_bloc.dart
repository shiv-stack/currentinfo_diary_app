import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/student_login_usecase.dart';
import '../../domain/usecases/get_class_notices_usecase.dart';
import '../../domain/usecases/get_attendance_usecase.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentLoginUseCase studentLoginUseCase;
  final GetClassNoticesUseCase getClassNoticesUseCase;
  final GetAttendanceUseCase getAttendanceUseCase;
  final AuthLocalDataSource authLocalDataSource;

  StudentBloc({
    required this.studentLoginUseCase,
    required this.getClassNoticesUseCase,
    required this.getAttendanceUseCase,
    required this.authLocalDataSource,
  }) : super(StudentInitial()) {
    on<StudentLoginSubmitted>(_onLoginSubmitted);
    on<GetClassNotices>(_onGetClassNotices);
    on<GetAttendance>(_onGetAttendance);
  }

  Future<void> _onLoginSubmitted(
    StudentLoginSubmitted event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());

    final result = await studentLoginUseCase(
      schoolCode: event.schoolCode,
      name: event.name,
      uniqueCode: event.uniqueCode,
    );

    await result.fold(
      (failure) async => emit(StudentLoginFailure(failure.message)),
      (student) async {
        if (student.cdiaryId != null) {
          await authLocalDataSource.cacheStudentId(student.cdiaryId!);
        }
        // Cache school-specific credentials
        await authLocalDataSource.cacheStudentCredentials(
          event.schoolCode,
          event.name,
          event.uniqueCode,
        );
        emit(StudentLoginSuccess(student));
      },
    );
  }

  Future<void> _onGetClassNotices(
    GetClassNotices event,
    Emitter<StudentState> emit,
  ) async {
    emit(ClassNoticesLoading());

    final result = await getClassNoticesUseCase(
      schoolCode: event.schoolCode,
      cdiaryId: event.cdiaryId,
      password: event.password,
      session: event.session,
      className: event.className,
      section: event.section,
    );

    result.fold(
      (failure) => emit(ClassNoticesFailure(failure.message)),
      (notices) => emit(ClassNoticesLoaded(notices)),
    );
  }

  Future<void> _onGetAttendance(
    GetAttendance event,
    Emitter<StudentState> emit,
  ) async {
    emit(AttendanceLoading());

    final result = await getAttendanceUseCase(
      schoolCode: event.schoolCode,
      cdiaryId: event.cdiaryId,
      password: event.password,
      session: event.session,
      month: event.month,
    );

    result.fold(
      (failure) => emit(AttendanceFailure(failure.message)),
      (attendance) => emit(AttendanceLoaded(attendance)),
    );
  }
}
