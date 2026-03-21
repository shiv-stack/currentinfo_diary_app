import 'package:equatable/equatable.dart';

class MarkDetailModel extends Equatable {
  final String? subject;
  final String? maxMarks;
  final String? marksObtained;
  final String? grade;

  const MarkDetailModel({
    this.subject,
    this.maxMarks,
    this.marksObtained,
    this.grade,
  });

  factory MarkDetailModel.fromJson(Map<String, dynamic> json) {
    return MarkDetailModel(
      subject: json['subject']?.toString() ?? json['subject_name']?.toString(),
      maxMarks: json['max_marks']?.toString() ?? json['out_of']?.toString(),
      marksObtained: json['marks_obtained']?.toString() ?? json['marks']?.toString(),
      grade: json['grade']?.toString(),
    );
  }

  @override
  List<Object?> get props => [subject, maxMarks, marksObtained, grade];
}
