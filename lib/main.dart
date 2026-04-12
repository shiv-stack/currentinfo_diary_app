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
import 'features/student/presentation/pages/marks_page.dart';
import 'features/student/presentation/pages/holiday_hw_page.dart';
import 'features/student/presentation/pages/syllabus_page.dart';
import 'features/student/presentation/pages/timetable_page.dart';
import 'features/student/presentation/pages/datesheet_page.dart';
import 'features/student/presentation/pages/student_profile_page.dart';
import 'features/student/presentation/pages/messages_page.dart';
import 'widgets/webview_page.dart';
import 'features/student/data/models/student_model.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/school_code_page.dart';
import 'features/auth/presentation/pages/student_login_page.dart';
import 'features/auth/presentation/pages/school_calendar_page.dart';
import 'features/auth/presentation/pages/query_page.dart';
import 'features/auth/presentation/bloc/query_bloc.dart';
import 'features/auth/data/models/school_model.dart';
import 'features/staff/presentation/pages/staff_login_page.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';
import 'routes/app_routes.dart';
import 'injection_container.dart' as di;

import 'package:hive_flutter/hive_flutter.dart';
import 'features/student/domain/entities/saved_student.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(SavedStudentAdapter());
  await di.init();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
        BlocProvider(create: (_) => di.sl<StaffBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
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
          AppRoutes.marks: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return MarksPage(student: student);
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
          AppRoutes.calendar: (_) => const SchoolCalendarPage(),
          AppRoutes.query: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return BlocProvider(
              create: (context) => di.sl<QueryBloc>(),
              child: QueryPage(
                school: args['school'] as SchoolModel,
                schoolCode: args['schoolCode'] as String,
              ),
            );
          },
          AppRoutes.holidayHw: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return HolidayHwPage(student: student);
          },
          AppRoutes.syllabus: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return SyllabusPage(student: student);
          },
          AppRoutes.timetable: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return TimetablePage(student: student);
          },
          AppRoutes.datesheet: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return DatesheetPage(student: student);
          },
          AppRoutes.profile: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return StudentProfilePage(student: student);
          },
          AppRoutes.messages: (context) {
            final student =
                ModalRoute.of(context)!.settings.arguments as StudentModel;
            return MessagesPage(student: student);
          },
          AppRoutes.staffLogin: (_) => const StaffLoginPage(),
        },
      ),
    );
  }
}
