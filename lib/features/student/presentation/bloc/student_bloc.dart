import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/student_login_usecase.dart';
import '../../domain/usecases/get_class_notices_usecase.dart';
import '../../domain/usecases/get_attendance_usecase.dart';
import '../../domain/usecases/get_assignments_usecase.dart';
import '../../domain/usecases/get_fees_usecase.dart';
import '../../domain/usecases/get_leaves_usecase.dart';
import '../../domain/usecases/apply_leave_usecase.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../data/datasources/student_local_data_source.dart';
import '../../domain/entities/saved_student.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentLoginUseCase studentLoginUseCase;
  final GetClassNoticesUseCase getClassNoticesUseCase;
  final GetAttendanceUseCase getAttendanceUseCase;
  final GetAssignmentsUseCase getAssignmentsUseCase;
  final GetFeesUseCase getFeesUseCase;
  final GetLeavesUseCase getLeavesUseCase;
  final ApplyLeaveUseCase applyLeaveUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final StudentLocalDataSource studentLocalDataSource;

  StudentBloc({
    required this.studentLoginUseCase,
    required this.getClassNoticesUseCase,
    required this.getAttendanceUseCase,
    required this.getAssignmentsUseCase,
    required this.getFeesUseCase,
    required this.getLeavesUseCase,
    required this.applyLeaveUseCase,
    required this.authLocalDataSource,
    required this.studentLocalDataSource,
  }) : super(StudentInitial()) {
    on<StudentLoginSubmitted>(_onLoginSubmitted);
    on<GetClassNotices>(_onGetClassNotices);
    on<GetAttendance>(_onGetAttendance);
    on<GetSavedStudents>(_onGetSavedStudents);
    on<DeleteSavedStudent>(_onDeleteSavedStudent);
    on<GetAssignments>(_onGetAssignments);
    on<GetFees>(_onGetFees);
    on<GetLeaves>(_onGetLeaves);
    on<ApplyLeave>(_onApplyLeave);
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
        // Cache school-specific credentials in SharedPreferences (for existing logic)
        await authLocalDataSource.cacheStudentCredentials(
          event.schoolCode,
          event.name,
          event.uniqueCode,
        );

        // EXTRA: Cache ACTIVE session for auto-login on app restart
        await authLocalDataSource.cacheActiveStudentCredentials(
          event.name,
          event.uniqueCode,
        );

        // EXTRA: Save to Hive for multi-account switching
        await studentLocalDataSource.saveStudent(SavedStudent(
          schoolCode: event.schoolCode,
          name: event.name,
          uniqueCode: event.uniqueCode,
          studentClass: student.className,
        ));

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

  Future<void> _onGetSavedStudents(
    GetSavedStudents event,
    Emitter<StudentState> emit,
  ) async {
    final students = await studentLocalDataSource.getSavedStudents();
    emit(SavedStudentsLoaded(students));
  }

  Future<void> _onDeleteSavedStudent(
    DeleteSavedStudent event,
    Emitter<StudentState> emit,
  ) async {
    await studentLocalDataSource.removeStudent(event.uniqueCode);
    final students = await studentLocalDataSource.getSavedStudents();
    emit(SavedStudentsLoaded(students));
  }

  Future<void> _onGetAssignments(
    GetAssignments event,
    Emitter<StudentState> emit,
  ) async {
    emit(AssignmentsLoading());

    final result = await getAssignmentsUseCase(
      schoolCode: event.schoolCode,
      cdiaryId: event.cdiaryId,
      password: event.password,
      session: event.session,
      month: event.month,
      day: event.day,
      studentClass: event.studentClass,
      section: event.section,
      showhw: event.showhw,
    );

    result.fold(
      (failure) => emit(AssignmentsFailure(failure.message)),
      (assignments) => emit(AssignmentsLoaded(assignments)),
    );
  }

  Future<void> _onGetFees(
    GetFees event,
    Emitter<StudentState> emit,
  ) async {
    emit(FeesLoading());

    final result = await getFeesUseCase(
      schoolCode: event.schoolCode,
      cdiaryId: event.cdiaryId,
      password: event.password,
      session: event.session,
      studentFeeSoftware: event.studentFeeSoftware,
    );

    result.fold(
      (failure) => emit(FeesFailure(failure.message)),
      (fees) => emit(FeesLoaded(fees)),
    );
  }

  Future<void> _onGetLeaves(
    GetLeaves event,
    Emitter<StudentState> emit,
  ) async {
    emit(LeavesLoading());

    final result = await getLeavesUseCase(
      schoolCode: event.schoolCode,
      studentId: event.studentId,
      password: event.password,
    );

    result.fold(
      (failure) => emit(LeavesFailure(failure.message)),
      (leaves) => emit(LeavesLoaded(leaves)),
    );
  }

  Future<void> _onApplyLeave(
    ApplyLeave event,
    Emitter<StudentState> emit,
  ) async {
    emit(LeaveApplying());

    final result = await applyLeaveUseCase(
      schoolCode: event.schoolCode,
      studentId: event.studentId,
      password: event.password,
      studentName: event.studentName,
      studentClass: event.studentClass,
      admissionRollNo: event.admissionRollNo,
      session: event.session,
      fromDate: event.fromDate,
      toDate: event.toDate,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(LeaveApplyFailure(failure.message)),
      (message) => emit(LeaveApplySuccess(message)),
    );
  }
}
