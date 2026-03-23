import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logLogin({required String userType, String? schoolCode}) async {
    await _analytics.logLogin(loginMethod: "form");
    await _analytics.setUserProperty(name: "user_type", value: userType);
    if (schoolCode != null) {
      await _analytics.setUserProperty(name: "school_code", value: schoolCode);
    }
  }

  Future<void> logDashboardAction(String actionName) async {
    await _analytics.logEvent(
      name: "dashboard_action",
      parameters: {
        "action": actionName,
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logSchoolSearch(String schoolCode) async {
    await _analytics.logEvent(
      name: "school_search",
      parameters: {"code": schoolCode},
    );
  }

  Future<void> logError(String errorCode, String message) async {
    await _analytics.logEvent(
      name: "app_error",
      parameters: {"code": errorCode, "message": message},
    );
  }
}
