import 'package:equatable/equatable.dart';

class Staff extends Equatable {
  final String? staffImage;
  final String? name;
  final String? designation;
  final String? dob;
  final String? contactNumber;
  final String? cdiaryId;
  final String? schoolName;
  final String? address;
  final String? email;
  final String? schoolCode;
  final String? password;

  // New columns from API response
  final String? feedbackUrl;
  final String? attendanceUrl;
  final String? controlSms;
  final String? month;
  final String? behaviourUrl;
  final String? checkPlanner;
  final String? uploadMarks;
  final String? checkAssignmentUrl;
  final String? assignmentUrl;
  final String? galleryNewUrlGlide;
  final String? galleryUrl;
  final String? vts;
  final String? costExpense;
  final String? contactSchool;
  final String? returnStatus;
  final String? tokenMainHit;
  final String? getPassword;

  const Staff({
    this.staffImage,
    this.name,
    this.designation,
    this.dob,
    this.contactNumber,
    this.cdiaryId,
    this.schoolName,
    this.address,
    this.email,
    this.schoolCode,
    this.password,
    this.feedbackUrl,
    this.attendanceUrl,
    this.controlSms,
    this.month,
    this.behaviourUrl,
    this.checkPlanner,
    this.uploadMarks,
    this.checkAssignmentUrl,
    this.assignmentUrl,
    this.galleryNewUrlGlide,
    this.galleryUrl,
    this.vts,
    this.costExpense,
    this.contactSchool,
    this.returnStatus,
    this.tokenMainHit,
    this.getPassword,
  });

  @override
  List<Object?> get props => [
        staffImage,
        name,
        designation,
        dob,
        contactNumber,
        cdiaryId,
        schoolName,
        address,
        email,
        schoolCode,
        password,
        feedbackUrl,
        attendanceUrl,
        controlSms,
        month,
        behaviourUrl,
        checkPlanner,
        uploadMarks,
        checkAssignmentUrl,
        assignmentUrl,
        galleryNewUrlGlide,
        galleryUrl,
        vts,
        costExpense,
        contactSchool,
        returnStatus,
        tokenMainHit,
        getPassword,
      ];
}
