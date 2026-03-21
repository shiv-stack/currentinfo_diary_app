import 'package:equatable/equatable.dart';

class ExamModel extends Equatable {
  final String? classInfo;
  final String? year;
  final String? examInfo;

  const ExamModel({
    this.classInfo,
    this.year,
    this.examInfo,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      classInfo: json['class-info']?.toString(),
      year: json['year']?.toString(),
      examInfo: json['exam-info']?.toString(),
    );
  }

  @override
  List<Object?> get props => [classInfo, year, examInfo];
}
