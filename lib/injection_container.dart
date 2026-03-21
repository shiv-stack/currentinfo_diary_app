import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_gallery_usecase.dart';
import 'features/auth/domain/usecases/get_school_info_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/gallery_bloc.dart';
import 'features/auth/presentation/bloc/query_bloc.dart';
import 'features/auth/domain/usecases/send_query_usecase.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/student/domain/usecases/student_login_usecase.dart';
import 'features/student/domain/usecases/get_class_notices_usecase.dart';
import 'features/student/domain/usecases/get_attendance_usecase.dart';
import 'features/student/domain/usecases/get_assignments_usecase.dart';
import 'features/student/domain/usecases/get_fees_usecase.dart';
import 'features/student/domain/usecases/get_leaves_usecase.dart';
import 'features/student/domain/usecases/apply_leave_usecase.dart';
import 'features/student/domain/usecases/get_exams_usecase.dart';
import 'features/student/domain/usecases/get_mark_details_usecase.dart';
import 'features/student/domain/repositories/student_repository.dart';
import 'features/student/data/repositories/student_repository_impl.dart';
import 'features/student/data/datasources/student_remote_data_source.dart';
import 'features/student/data/datasources/student_local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getSchoolInfoUseCase: sl(),
      studentLoginUseCase: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerFactory(() => GalleryBloc(getGalleryUseCase: sl()));
  sl.registerFactory(() => QueryBloc(sendQueryUseCase: sl()));
  sl.registerFactory(
    () => StudentBloc(
      studentLoginUseCase: sl(),
      getClassNoticesUseCase: sl(),
      getAttendanceUseCase: sl(),
      getAssignmentsUseCase: sl(),
      getFeesUseCase: sl(),
      getExamsUseCase: sl(),
      getMarkDetailsUseCase: sl(),
      getLeavesUseCase: sl(),
      applyLeaveUseCase: sl(),
      authLocalDataSource: sl(),
      studentLocalDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSchoolInfoUseCase(sl()));
  sl.registerLazySingleton(() => GetGalleryUseCase(sl()));
  sl.registerLazySingleton(() => SendQueryUseCase(sl()));
  sl.registerLazySingleton(() => StudentLoginUseCase(sl()));
  sl.registerLazySingleton(() => GetClassNoticesUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetFeesUseCase(sl()));
  sl.registerLazySingleton(() => GetExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetMarkDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetLeavesUseCase(sl()));
  sl.registerLazySingleton(() => ApplyLeaveUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<StudentLocalDataSource>(
    () => StudentLocalDataSourceImpl(),
  );
}
