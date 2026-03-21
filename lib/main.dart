import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/gallery_bloc.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/auth/presentation/pages/gallery_page.dart';
import 'features/auth/presentation/pages/notice_page.dart';
import 'features/student/presentation/pages/class_notice_page.dart';
import 'features/student/presentation/pages/attendance_page.dart';
import 'features/student/presentation/pages/assignment_page.dart';
import 'features/student/presentation/pages/fee_page.dart';
import 'features/student/presentation/pages/leave_page.dart';
import 'widgets/webview_page.dart';
import 'features/student/data/models/student_model.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/school_code_page.dart';
import 'features/auth/presentation/pages/student_login_page.dart';
import 'routes/app_routes.dart';
import 'injection_container.dart' as di;

import 'package:hive_flutter/hive_flutter.dart';
import 'features/student/domain/entities/saved_student.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SavedStudentAdapter());
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<GalleryBloc>()),
        BlocProvider(create: (_) => di.sl<StudentBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Current Diary',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashPage(),
          AppRoutes.schoolCode: (_) => const SchoolCodePage(),
          AppRoutes.gallery: (_) => const GalleryPage(),
          AppRoutes.studentLogin: (_) => const StudentLoginPage(),
          AppRoutes.notice: (_) => const NoticePage(),
          AppRoutes.classNotice: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return ClassNoticePage(student: student);
          },
          AppRoutes.attendance: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return AttendancePage(student: student);
          },
          AppRoutes.homework: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return AssignmentPage(student: student);
          },
          AppRoutes.fees: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return FeePage(student: student);
          },
          AppRoutes.leave: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return LeavePage(student: student);
          },
          AppRoutes.webView: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return WebViewPage(
              title: args['title'] as String,
              url: args['url'] as String,
            );
          },
        },
      ),
    );
  }
}
