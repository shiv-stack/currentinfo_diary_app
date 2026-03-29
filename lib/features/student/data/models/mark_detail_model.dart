import 'package:equatable/equatable.dart';

class MarkDetailModel extends Equatable {
  final String? subject;
  final String? maxMarks;
  final String? marksObtained;
  final String? grade;
  final String? rollNo;
  final String? attendance;
  final String? enrollmentNumber;
  final String? totalAttendance;

  const MarkDetailModel({
    this.subject,
    this.maxMarks,
    this.marksObtained,
    this.grade,
    this.rollNo,
    this.attendance,
    this.enrollmentNumber,
    this.totalAttendance,
  });

  factory MarkDetailModel.fromJson(Map<String, dynamic> json) {
    return MarkDetailModel(
      subject: json['subject']?.toString() ?? json['subject_name']?.toString(),
      maxMarks: json['max_marks']?.toString() ?? json['out_of']?.toString(),
      marksObtained:
          json['marks_obtained']?.toString() ?? json['marks']?.toString(),
      grade: json['grade']?.toString(),
      rollNo: json['rollno']?.toString(),
      attendance: json['attendance']?.toString(),
      enrollmentNumber: json['enrollment_number']?.toString(),
      totalAttendance: json['totalattendance']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        subject,
        maxMarks,
        marksObtained,
        grade,
        rollNo,
        attendance,
        enrollmentNumber,
        totalAttendance,
      ];
}
