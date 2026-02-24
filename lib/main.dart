import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/gallery_bloc.dart';
import 'features/auth/presentation/pages/gallery_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/school_code_page.dart';
import 'routes/app_routes.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // Load saved theme
  final prefs = di.sl<SharedPreferences>();
  final savedTheme = prefs.getString('theme_mode');
  if (savedTheme != null) {
    themeNotifier.value = savedTheme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // Listen for changes and save
  themeNotifier.addListener(() {
    prefs.setString(
      'theme_mode',
      themeNotifier.value == ThemeMode.dark ? 'dark' : 'light',
    );
  });

  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<GalleryBloc>()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashPage(),
              AppRoutes.schoolCode: (_) => const SchoolCodePage(),
              AppRoutes.gallery: (_) => const GalleryPage(),
            },
          );
        },
      ),
    );
  }
}
