import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/gallery_bloc.dart';
import 'features/auth/presentation/pages/gallery_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/school_code_page.dart';
import 'features/auth/presentation/pages/student_login_page.dart';
import 'routes/app_routes.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Current Diary',
        theme: AppTheme.lightTheme,
        // Optional: Support dark theme if requested
        // darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashPage(),
          AppRoutes.schoolCode: (_) => const SchoolCodePage(),
          AppRoutes.gallery: (_) => const GalleryPage(),
          AppRoutes.studentLogin: (_) => const StudentLoginPage(),
        },
      ),
    );
  }
}
