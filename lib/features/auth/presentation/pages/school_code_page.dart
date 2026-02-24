import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:current_diary_app/core/constants/app_colors.dart';
import 'package:current_diary_app/widgets/primary_button.dart';
import 'package:current_diary_app/widgets/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/main.dart';
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
  int _currentIndex = 0;
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
          if (state.message.contains("Connected")) {
            setState(() {
              _currentIndex = 0;
            });
          }
          _showFullWidthToast(state.message, Colors.green);
        } else if (state is AuthError) {
          _showFullWidthToast("Invalid School Code", AppColors.error);
        }
      },
      builder: (context, state) {
        bool isConnected = state is AuthSuccess && state.school != null;
        final school = isConnected ? state.school : null;

        if (isConnected) {
          return Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeSection(school!),
                    const Center(child: Text("Notifications (Coming Soon)")),
                    const Center(child: Text("Support (Coming Soon)")),
                    _buildMeSection(school),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildCustomNavBar(),
                ),
              ],
            ),
          );
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

  Widget _buildHomeSection(dynamic school) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          stretch: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            titlePadding: EdgeInsets.zero,
            centerTitle: false,
            title: LayoutBuilder(
              builder: (context, constraints) {
                final double percentage =
                    (constraints.maxHeight - kToolbarHeight) /
                    (200 - kToolbarHeight);
                final bool isCollapsed = percentage < 0.2;

                return Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    bottom: isCollapsed ? 15 : 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isCollapsed)
                        Hero(
                          tag: 'school_logo_mini',
                          child: Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                school.schoolLogo ?? "",
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.school_rounded,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          school!.title?.toUpperCase() ?? "SCHOOL",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: isCollapsed ? 16 : 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 60,
                    child: Hero(
                      tag: 'school_logo_main',
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.network(
                              school.schoolLogo ?? "",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.school_rounded,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                color: Colors.black.withValues(alpha: 0.15),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Services",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Session: ${school.session ?? 'N/A'}",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.calendar_today_rounded,
                      "Attendance",
                      Colors.blue,
                      school.attendanceUrl,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.table_chart_rounded,
                      "Timetable",
                      Colors.orange,
                      school.timetableUrl,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.assignment_rounded,
                      "Materials",
                      Colors.purple,
                      school.assignmentsUrl,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.photo_library_rounded,
                      "Gallery",
                      Colors.pink,
                      school.galleryUrl,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.grade_rounded,
                      "Report Card",
                      Colors.teal,
                      school.marksUrl,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.info_outline_rounded,
                      "Admission",
                      Colors.indigo,
                      school.onlineAdmissionUrl,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (school.todayThought != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.format_quote_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            school.todayThought!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeSection(dynamic school) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  school.schoolLogo ?? "",
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.school_rounded,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "School Profile",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildSettingsTile(
            icon: Icons.dark_mode_rounded,
            title: "Dark Mode",
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                return Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (val) {
                    themeNotifier.value = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                );
              },
            ),
          ),

          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: "Help & Support",
            onTap: () {},
          ),
          const SizedBox(height: 40),
          PrimaryButton(
            title: "DISCONNECT SCHOOL",
            color: AppColors.error,
            onPressed: () => _showDisconnectDialog(context),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
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

  Widget _buildCustomNavBar() {
    final items = [
      {'icon': Icons.home_rounded, 'title': 'Home'},
      {'icon': Icons.notifications_rounded, 'title': 'Notice'},
      {'icon': Icons.chat_bubble_rounded, 'title': 'Help'},
      {'icon': Icons.person_rounded, 'title': 'Me'},
    ];

    return SafeArea(
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _currentIndex == index;
            final item = items[index];
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white.withValues(alpha: 0.7),
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    String? url,
  ) {
    return InkWell(
      onTap: () => _openUrl(context, title, url),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String title, String? url) {
    if (title == "Gallery") {
      Navigator.pushNamed(context, AppRoutes.gallery);
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
