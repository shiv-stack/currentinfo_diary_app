import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/usecases/get_school_info_usecase.dart';
import '../../../student/domain/usecases/student_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetSchoolInfoUseCase getSchoolInfoUseCase;
  final StudentLoginUseCase studentLoginUseCase;
  final AuthLocalDataSource localDataSource;

  AuthBloc({
    required this.getSchoolInfoUseCase,
    required this.studentLoginUseCase,
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
    await localDataSource.clearActiveStudentSession();
    final storedCode = await localDataSource.getCachedSchoolCode();
    final cachedSchool = await localDataSource.getCachedSchoolInfo();

    if (storedCode != null && cachedSchool != null) {
      emit(
        AuthSuccess(
          message: "Logged out from Student Profile",
          school: cachedSchool,
          schoolCode: storedCode,
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

    // CHECK FOR ACTIVE STUDENT SESSION (FOR AUTO-LOGIN)
    final activeCreds = await localDataSource.getActiveStudentCredentials();
    if (activeCreds != null) {
      final name = activeCreds['name'];
      final pass = activeCreds['password'];
      if (name != null && pass != null) {
        final loginResult = await studentLoginUseCase(
          schoolCode: storedCode,
          name: name,
          uniqueCode: pass,
        );
        
        // If login is successful, we go straight to student dashboard
        final bool shouldReturn = await loginResult.fold(
          (failure) async => false, // Continue to school check if student login fails
          (student) async {
            emit(StudentAuthenticated(student));
            return true;
          },
        );
        if (shouldReturn) return;
      }
    }

    // Attempt instant load of school info from cache
    final cachedSchool = await localDataSource.getCachedSchoolInfo();
    if (cachedSchool != null) {
      emit(
        AuthSuccess(
          message: "Welcome back to ${cachedSchool.title}",
          school: cachedSchool,
          schoolCode: storedCode,
        ),
      );
    } else {
      emit(AuthLoading());
    }

    // Refresh data from API
    final result = await getSchoolInfoUseCase(storedCode);

    await result.fold(
      (failure) async {
        // If we don't even have cached info, redirect to login
        if (cachedSchool == null) {
          emit(NavigateToSchoolCode());
        }
      },
      (school) async {
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
        emit(AuthSuccess(
            message: "Data Updated", school: school, schoolCode: storedCode));
      },
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
      emit(
        AuthSuccess(
          message: "Connected to ${school.title ?? 'School'}",
          school: school,
          schoolCode: event.code,
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
