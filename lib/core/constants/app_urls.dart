class AppUrls {
  AppUrls._();

  static const String baseUrl = "https://www.currentdiary.com";

  // Auth / School Info
  static String getSchoolInfo(String code) =>
      "$baseUrl/school-info/api-app-currentdiary/$code/";

  static String getGallery(String code) =>
      "$baseUrl/school-info/new-gallery/$code/";

  static String getCalendar(String code) =>
      "$baseUrl/school-calendar/update-calendar/$code/";

  // Student
  static String studentLogin(String schoolCode) =>
      "$baseUrl/student-info/api-request-school/$schoolCode/";

  static String getClassNotices(String schoolCode) =>
      "https://www.padhebharat.com/school-notice/school-notice-class-school-cdiary/$schoolCode/";

  static String getAttendance(String schoolCode) =>
      "$baseUrl/school-attendance/api-school-attendance-api/$schoolCode/";

  static String getAssignments(String schoolCode) =>
      "$baseUrl/assignment/assignment-school/$schoolCode/";

  static String getFees(String schoolCode) =>
      "$baseUrl/feemanage/fee-quick-app-api/$schoolCode/";

  static String getMultitask(String schoolCode) =>
      "$baseUrl/multitask/multitask/$schoolCode/";

  static String getMarks(String schoolCode) =>
      "$baseUrl/marks-record/marks-school-all/$schoolCode/";

  static String sendQuery(String schoolCode) =>
      "$baseUrl/contact-to-school/sent-message-to-school/$schoolCode/";

  static String updatePassword(String schoolCode) =>
      "$baseUrl/student-info/update-record-school/$schoolCode/";

  static String getMessages(String schoolCode) =>
      "https://www.padhebharat.com/multitask/multitask-message/$schoolCode/";
}
