class AppUrls {
  AppUrls._();

  static const String baseUrl = "https://www.currentdiary.com";

  // Auth / School Info
  static String getSchoolInfo(String code) =>
      "$baseUrl/school-info/api-app-currentdiary/$code/";

  static String getGallery(String code) => 
      "$baseUrl/school-info/new-gallery/$code/";

  // Student
  static String studentLogin(String schoolCode) =>
      "$baseUrl/student-info/api-request-school/$schoolCode/";

  static String getClassNotice(String schoolCode) =>
      "https://www.padhebharat.com/school-notice/school-notice-class-school-cdiary/$schoolCode/";

  static String getAttendance(String schoolCode) =>
      "$baseUrl/school-attendance/api-school-attendance-api/$schoolCode/";

  static String getHomework(String schoolCode) =>
      "$baseUrl/assignment/assignment-school/$schoolCode";

  static String getFees(String schoolCode) => 
      "$baseUrl/feemanage/fee-quick-app-api/$schoolCode/";
}
