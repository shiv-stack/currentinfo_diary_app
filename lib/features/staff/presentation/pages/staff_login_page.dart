import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'staff_dashboard_page.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _schoolName;

  @override
  void initState() {
    super.initState();
    _loadSchoolInfo();
  }

  void _loadSchoolInfo() async {
    final school = await di.sl<AuthLocalDataSource>().getCachedSchoolInfo();
    if (mounted) {
      setState(() {
        _schoolName = school?.title;
      });
    }
  }

  void _onLoginPressed(BuildContext context) async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      AppToast.show(context, "Please enter name and password", isError: true);
      return;
    }

    final code = await di.sl<AuthLocalDataSource>().getCachedSchoolCode();
    if (code == null || code.isEmpty) {
      AppToast.show(context, "School code missing. Please connect again.", isError: true);
      return;
    }

    context.read<StaffBloc>().add(
      StaffLoginSubmitted(
        schoolCode: code,
        name: name,
        uniqueCode: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffLoginSuccess) {
            AppToast.show(context, "Login Successful");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => StaffDashboardPage(staff: state.staff),
              ),
              (route) => false,
            );
          } else if (state is StaffLoginFailure) {
            AppToast.show(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/staff_login.png',
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                    scale: 3.0,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              _schoolName ?? "Staff portal".toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Staff Login",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1C1E),
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Welcome back! Please sign in to manage your school diary.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: "Staff Name",
                                    icon: Icons.badge_rounded,
                                    context: context,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: "Unique Code",
                                    icon: Icons.lock_rounded,
                                    isPassword: true,
                                    isVisible: _isPasswordVisible,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                    context: context,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: BlocBuilder<StaffBloc, StaffState>(
                                      builder: (context, state) {
                                        final isLoading = state is StaffLoading;
                                        return ElevatedButton(
                                          onPressed: isLoading ? null : () => _onLoginPressed(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: AppLoadingIndicator(
                                                    centered: false,
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  "SIGN IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onToggleVisibility,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
