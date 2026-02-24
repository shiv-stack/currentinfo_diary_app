class AppUrls {
  AppUrls._();

  static const String baseUrl = "https://www.currentdiary.com/school-info";
  static const String apiAppCurrentDiary = "/api-app-currentdiary";

  static String getSchoolInfo(String code) =>
      "$baseUrl$apiAppCurrentDiary/$code/";

  static String getGallery(String code) => "$baseUrl/new-gallery/$code/";
}
