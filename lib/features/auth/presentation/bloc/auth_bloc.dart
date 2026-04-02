import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/usecases/get_school_info_usecase.dart';
import '../../../student/domain/usecases/student_login_usecase.dart';
import '../../../student/domain/usecases/logout_notification_usecase.dart';
import '../../../student/data/models/student_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetSchoolInfoUseCase getSchoolInfoUseCase;
  final StudentLoginUseCase studentLoginUseCase;
  final LogoutNotificationUseCase logoutNotificationUseCase;
  final AuthLocalDataSource localDataSource;

  AuthBloc({
    required this.getSchoolInfoUseCase,
    required this.studentLoginUseCase,
    required this.logoutNotificationUseCase,
    required this.localDataSource,
  }) : super(AuthInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SubmitSchoolCode>(_onSubmit);
    on<DisconnectSchool>(_onDisconnect);
    on<SkipPressed>(_onSkip);
    on<StudentLogout>(_onStudentLogout);
  }

  Future<void> _onStudentLogout(
    StudentLogout event,
    Emitter<AuthState> emit,
  ) async {
    final creds = await localDataSource.getActiveStudentCredentials();
    final schoolCode = await localDataSource.getCachedSchoolCode();

    if (creds != null && schoolCode != null) {
      // Notify server about logout (unsubscribe push notifications)
      await logoutNotificationUseCase(
        schoolCode: schoolCode,
        name: creds['name'] ?? "",
        uniqueCode: creds['password'] ?? "",
      );
    }

    await localDataSource.clearActiveStudentSession();
    final storedCode = await localDataSource.getCachedSchoolCode();
    final cachedSchool = await localDataSource.getCachedSchoolInfo();

    if (storedCode != null && cachedSchool != null) {
      emit(
        AuthSuccess(
          message: "Logged out from Student Profile",
          school: cachedSchool,
          schoolCode: storedCode,
          feesoftware: cachedSchool.feeSoftware,
        ),
      );
    } else {
      emit(NavigateToSchoolCode());
    }
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    add(CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final storedCode = await localDataSource.getCachedSchoolCode();

    if (storedCode == null || storedCode.isEmpty) {
      emit(NavigateToSchoolCode());
      return;
    }

    // Attempt instant load of school info from cache
    final cachedSchool = await localDataSource.getCachedSchoolInfo();
    if (cachedSchool != null) {
      emit(
        AuthSuccess(
          message: "Welcome back",
          school: cachedSchool,
          schoolCode: storedCode,
          feesoftware: cachedSchool.feeSoftware,
        ),
      );
    } else {
      emit(AuthLoading());
    }

    // MANDATORY REFRESH: Update cached school values from API
    final schoolResult = await getSchoolInfoUseCase(storedCode);
    final school = await schoolResult.fold(
      (failure) async {
        debugPrint("School refresh failed: ${failure.message}");
        if (cachedSchool == null) {
          emit(NavigateToSchoolCode());
        }
        return cachedSchool;
      },
      (freshSchool) async {
        await localDataSource.cacheSchoolInfo(freshSchool);
        if (freshSchool.session != null) {
          await localDataSource.cacheSession(freshSchool.session!);
        }
        if (freshSchool.onlineFeeSubmit != null) {
          await localDataSource.cacheOnlineFeeSubmit(
            freshSchool.onlineFeeSubmit!,
          );
        }
        if (freshSchool.feeSoftware != null) {
          await localDataSource.cacheFeeSoftware(freshSchool.feeSoftware!);
        }
        if (freshSchool.leaveOptionInApp != null) {
          await localDataSource.cacheLeaveOption(freshSchool.leaveOptionInApp!);
        }
        return freshSchool;
      },
    );
    debugPrint("School code refreshed: $storedCode");

    if (school == null) return;

    // CHECK FOR ACTIVE STUDENT SESSION (FOR AUTO-LOGIN RE-VERIFICATION)
    final activeCreds = await localDataSource.getActiveStudentCredentials();
    if (activeCreds != null) {
      final name = activeCreds['name'];
      final pass = activeCreds['password'];
      if (name != null && pass != null) {
        debugPrint("Re-verifying student session: $name");
        final loginResult = await studentLoginUseCase(
          schoolCode: storedCode,
          name: name,
          uniqueCode: pass,
        );

        final bool shouldReturn = await loginResult.fold(
          (failure) async {
            debugPrint("Re-verification failed: ${failure.message}");
            if (failure.message.toLowerCase().contains("invalid") ||
                failure.message.toLowerCase().contains("not found")) {
              await localDataSource.clearActiveStudentSession();
              return false;
            }
            return false;
          },
          (student) async {
            debugPrint("Re-verification successful for ${student.name}");
            // Merge feesoftware from school info if not present in student
            final updatedStudent = StudentModel(
              studentImage: student.studentImage,
              thoughtTitle: student.thoughtTitle,
              thoughtMessage: student.thoughtMessage,
              name: student.name,
              className: student.className,
              dob: student.dob,
              contactNumber: student.contactNumber,
              cdiaryId: student.cdiaryId,
              section: student.section,
              session: student.session,
              schoolName: student.schoolName,
              address: student.address,
              email: student.email,
              fatherName: student.fatherName,
              motherName: student.motherName,
              schoolCode: student.schoolCode,
              enrollNumber: student.enrollNumber,
              password: student.password,
              feesoftware: student.feesoftware ?? school.feeSoftware,
              doa: student.doa,
            );
            emit(StudentAuthenticated(updatedStudent, school: school));
            return true;
          },
        );
        if (shouldReturn) return;
      }
    }

    // Emit the fresh school info context
    emit(
      AuthSuccess(
        message: "Data Updated",
        school: school,
        schoolCode: storedCode,
        feesoftware: school.feeSoftware,
      ),
    );
  }

  Future<void> _onSubmit(
    SubmitSchoolCode event,
    Emitter<AuthState> emit,
  ) async {
    if (event.code.isEmpty) {
      emit(AuthError("Please enter school code"));
      return;
    }

    emit(AuthLoading());

    final result = await getSchoolInfoUseCase(event.code);

    await result.fold((failure) async => emit(AuthError(failure.message)), (
      school,
    ) async {
      await localDataSource.cacheSchoolCode(event.code);
      await localDataSource.cacheSchoolInfo(school);
      if (school.session != null) {
        await localDataSource.cacheSession(school.session!);
      }
      if (school.onlineFeeSubmit != null) {
        await localDataSource.cacheOnlineFeeSubmit(school.onlineFeeSubmit!);
      }
      if (school.feeSoftware != null) {
        await localDataSource.cacheFeeSoftware(school.feeSoftware!);
      }
      if (school.leaveOptionInApp != null) {
        await localDataSource.cacheLeaveOption(school.leaveOptionInApp!);
      }
      emit(
        AuthSuccess(
          message: "Connected to ${school.title ?? 'School'}",
          school: school,
          schoolCode: event.code,
          feesoftware: school.feeSoftware,
        ),
      );
    });
  }

  Future<void> _onDisconnect(
    DisconnectSchool event,
    Emitter<AuthState> emit,
  ) async {
    await localDataSource.clearAuthData();
    emit(NavigateToSchoolCode());
  }

  void _onSkip(SkipPressed event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
