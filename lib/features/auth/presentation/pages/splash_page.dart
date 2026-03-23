import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../routes/app_routes.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../student/presentation/pages/student_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // 1. Check for updates first
    final remoteConfig = sl<RemoteConfigService>();
    final isUpdateRequired = await remoteConfig.shouldForceUpdate();

    if (isUpdateRequired && mounted) {
      _showUpdateDialog(remoteConfig.updateUrl);
      return;
    }

    // 2. Start normal auth flow if no update is required
    if (mounted) {
      context.read<AuthBloc>().add(SplashStarted());
    }
  }

  void _showUpdateDialog(String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Update Required",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "A critical new version of the app is available. Please update to continue using the application.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse(updateUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                "UPDATE NOW",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is StudentAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardPage(student: state.student),
            ),
          );
        } else if (state is NavigateToSchoolCode || state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, AppRoutes.schoolCode);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: SizedBox.expand(
            child: Image.asset('assets/images/splash.jpg', fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
