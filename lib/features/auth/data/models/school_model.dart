import 'package:equatable/equatable.dart';

class SchoolModel extends Equatable {
  final String? title;
  final String? schoolLogo;
  final String? todayThought;
  final String? schoolAddress;
  final String? contactNo;
  final String? schoolEmail;
  final String? imageValue1;
  final String? imageValue2;
  final String? imageValue3;
  final String? imageValue4;
  final String? onlineAdmissionUrl;
  final String? attendanceUrl;
  final String? timetableUrl;
  final String? assignmentsUrl;
  final String? galleryUrl;
  final String? marksUrl;
  final String? session;

  const SchoolModel({
    this.title,
    this.schoolLogo,
    this.todayThought,
    this.schoolAddress,
    this.contactNo,
    this.schoolEmail,
    this.imageValue1,
    this.imageValue2,
    this.imageValue3,
    this.imageValue4,
    this.onlineAdmissionUrl,
    this.attendanceUrl,
    this.timetableUrl,
    this.assignmentsUrl,
    this.galleryUrl,
    this.marksUrl,
    this.session,
  });

  List<String> get carouselImages {
    final images = <String>[];
    if (imageValue1 != null) images.add(imageValue1!);
    if (imageValue2 != null) images.add(imageValue2!);
    if (imageValue3 != null) images.add(imageValue3!);
    if (imageValue4 != null) images.add(imageValue4!);
    return images;
  }

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      title: json['title'] as String?,
      schoolLogo: json['schoollogo'] as String?,
      todayThought: json['today-thought'] as String?,
      schoolAddress: json['schooladdress'] as String?,
      contactNo: json['supportnumber'] as String?,
      schoolEmail: json['email'] as String?,
      imageValue1: json['imagevalue1'] as String?,
      imageValue2: json['imagevalue2'] as String?,
      imageValue3: json['imagevalue3'] as String?,
      imageValue4: json['imagevalue4'] as String?,
      onlineAdmissionUrl: json['onlineadmissionurl'] as String?,
      attendanceUrl: json['attendance_url_hit'] as String?,
      timetableUrl: json['timetable_url_new'] as String?,
      assignmentsUrl: json['check_assignment_url'] as String?,
      galleryUrl: json['gallery_new_url'] as String?,
      marksUrl: json['mark_url_new'] as String?,
      session: json['session'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'schoollogo': schoolLogo,
      'today-thought': todayThought,
      'schooladdress': schoolAddress,
      'supportnumber': contactNo,
      'email': schoolEmail,
      'imagevalue1': imageValue1,
      'imagevalue2': imageValue2,
      'imagevalue3': imageValue3,
      'imagevalue4': imageValue4,
      'onlineadmissionurl': onlineAdmissionUrl,
      'attendance_url_hit': attendanceUrl,
      'timetable_url_new': timetableUrl,
      'check_assignment_url': assignmentsUrl,
      'gallery_new_url': galleryUrl,
      'mark_url_new': marksUrl,
      'session': session,
    };
  }

  @override
  List<Object?> get props => [
    title,
    schoolLogo,
    todayThought,
    schoolAddress,
    contactNo,
    schoolEmail,
    imageValue1,
    imageValue2,
    imageValue3,
    imageValue4,
    onlineAdmissionUrl,
    attendanceUrl,
    timetableUrl,
    assignmentsUrl,
    galleryUrl,
    marksUrl,
    session,
  ];
}
