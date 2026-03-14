import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:current_diary_app/core/constants/app_colors.dart';
import 'package:current_diary_app/widgets/primary_button.dart';
import 'package:current_diary_app/widgets/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SchoolCodePage extends StatefulWidget {
  const SchoolCodePage({super.key});

  @override
  State<SchoolCodePage> createState() => _SchoolCodePageState();
}

class _SchoolCodePageState extends State<SchoolCodePage> {
  final TextEditingController controller = TextEditingController();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  void _showFullWidthToast(String message, Color color) {
    final bool isError = color == AppColors.error;

    Widget toast = Container(
      width: MediaQuery.of(context).size.width - 48,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    fToast.removeCustomToast();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _showFullWidthToast(state.message, Colors.green);
        } else if (state is AuthError) {
          _showFullWidthToast("Invalid School Code", AppColors.error);
        }
      },
      builder: (context, state) {
        bool isConnected = state is AuthSuccess && state.school != null;
        final school = isConnected ? state.school : null;

        if (isConnected) {
          return _buildHomeSection(context, school!);
        }

        return Scaffold(
          appBar: AppBar(title: const Text("CURRENT DIARY"), centerTitle: true),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.school_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Connect to Your School",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please enter the unique school code provided by your institution to access your digital diary.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "eg. SCH-123456",
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    PrimaryButton(
                      title: "CONNECT",
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          SubmitSchoolCode(controller.text),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeSection(BuildContext context, dynamic school) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom dynamically-sized Sticky Header instead of fixed-height AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              // Optional subtle shadow to separate from background
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).shadowColor.withValues(alpha: 0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'school_logo_main',
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.network(
                            school.schoolLogo ?? "",
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.school_rounded,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      school.title?.toUpperCase() ?? "SCHOOL",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        height: 1.3, // Slightly more space for readability
                      ),
                      // Allow up to 4 lines for huge names (approx 7-10 words) smoothly
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSelected: (value) {
                      if (value == 'disconnect') {
                        _showDisconnectDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'disconnect',
                            child: Text('Disconnect School'),
                          ),
                        ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (school.todayThought != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_outlined,
                                    size: 28,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Thought of the day",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.cloud_outlined,
                                    size: 28,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                school.todayThought!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.9,
                        children: [
                          _buildMenuItem(
                            context,
                            Icons.person_outline,
                            "Staff Login",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/staff_login.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.school_outlined,
                            "Student Login",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/student_login.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.room_service_outlined,
                            "Reception",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/reception.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.web_outlined,
                            "Web Staff Login",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/web_staff_login.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.web_outlined,
                            "Web Student Login",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/web_student_login.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.send_outlined,
                            "Send Query",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/send_query.png',
                          ),
                          _buildMenuItem(
                            context,
                            Icons.format_list_bulleted_outlined,
                            "Enquiry Form",
                            Colors.transparent,
                            null,
                            assetPath: 'assets/images/reception.png',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      if (school.carouselImages.isNotEmpty) ...[
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 180.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            autoPlayInterval: const Duration(seconds: 5),
                          ),
                          items: school.carouselImages.map<Widget>((imageUrl) {
                            return GestureDetector(
                              onTap: () => _openUrl(
                                context,
                                "Admission",
                                school.onlineAdmissionUrl,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).shadowColor.withValues(alpha: 0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    imageUrl as String,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          "Support : 9808166564",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 16),
                      // Center(
                      //   child: TextButton(
                      //     onPressed: () {},
                      //     child: Text(
                      //       "Forgot Student Password , Click",
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         color: Theme.of(context).colorScheme.primary,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disconnect School?"),
        content: const Text(
          "Are you sure you want to disconnect from this school? You will need the school code to connect again.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(DisconnectSchool());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("DISCONNECT"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    String? url, {
    String? assetPath,
  }) {
    return InkWell(
      onTap: () => _openUrl(context, title, url),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: assetPath != null
                  ? Image.asset(assetPath, fit: BoxFit.contain)
                  : Icon(icon, color: color, size: 32),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openUrl(BuildContext context, String title, String? url) {
    if (title == "Gallery") {
      Navigator.pushNamed(context, AppRoutes.gallery);
      return;
    }

    if (title == "Student Login") {
      Navigator.pushNamed(context, AppRoutes.studentLogin);
      return;
    }

    if (url != null && url != "NA" && url.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(title: title, url: url),
        ),
      );
    } else {
      _showFullWidthToast(
        "$title is Coming Soon",
        Theme.of(context).primaryColor,
      );
      HapticFeedback.lightImpact();
    }
  }
}
