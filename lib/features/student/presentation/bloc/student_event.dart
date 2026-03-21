import 'package:equatable/equatable.dart';


abstract class StudentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentLoginSubmitted extends StudentEvent {
  final String schoolCode;
  final String name;
  final String uniqueCode;

  StudentLoginSubmitted({
    required this.schoolCode,
    required this.name,
    required this.uniqueCode,
  });

  @override
  List<Object?> get props => [schoolCode, name, uniqueCode];
}

class GetClassNotices extends StudentEvent {
  final String schoolCode;
  final String cdiaryId;
  final String password;
  final String session;
  final String className;
  final String section;

  GetClassNotices({
    required this.schoolCode,
    required this.cdiaryId,
    required this.password,
    required this.session,
    required this.className,
    required this.section,
  });

  @override
  List<Object?> get props => [
        schoolCode,
        cdiaryId,
        password,
        session,
        className,
        section,
      ];
}

class GetAttendance extends StudentEvent {
  final String schoolCode;
  final String cdiaryId;
  final String password;
  final String session;
  final String month;

  GetAttendance({
    required this.schoolCode,
    required this.cdiaryId,
    required this.password,
    required this.session,
    required this.month,
  });

  @override
  List<Object?> get props => [
        schoolCode,
        cdiaryId,
        password,
        session,
        month,
      ];
}

class GetSavedStudents extends StudentEvent {}

class DeleteSavedStudent extends StudentEvent {
  final String uniqueCode;
  DeleteSavedStudent(this.uniqueCode);

  @override
  List<Object?> get props => [uniqueCode];
}

class GetAssignments extends StudentEvent {
  final String schoolCode;
  final String cdiaryId;
  final String password;
  final String session;
  final String month;
  final String day;
  final String studentClass;
  final String section;
  final String showhw;

  GetAssignments({
    required this.schoolCode,
    required this.cdiaryId,
    required this.password,
    required this.session,
    required this.month,
    required this.day,
    required this.studentClass,
    required this.section,
    required this.showhw,
  });

  @override
  List<Object?> get props => [
    schoolCode,
    cdiaryId,
    password,
    session,
    month,
    day,
    studentClass,
    section,
    showhw,
  ];
}

class GetFees extends StudentEvent {
  final String schoolCode;
  final String cdiaryId;
  final String password;
  final String session;
  final String studentFeeSoftware;

  GetFees({
    required this.schoolCode,
    required this.cdiaryId,
    required this.password,
    required this.session,
    required this.studentFeeSoftware,
  });

  @override
  List<Object?> get props => [
    schoolCode,
    cdiaryId,
    password,
    session,
    studentFeeSoftware,
  ];
}
