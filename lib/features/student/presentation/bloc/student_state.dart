import 'package:equatable/equatable.dart';
import '../../data/models/student_model.dart';
import '../../data/models/leave_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/mark_detail_model.dart';

abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}
// ... existing states ...
class StudentLoginSuccess extends StudentState {
  final StudentModel student;

  StudentLoginSuccess(this.student);

  @override
  List<Object?> get props => [student];
}

class StudentLoginFailure extends StudentState {
  final String message;

  StudentLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ClassNoticesLoading extends StudentState {}

class ClassNoticesLoaded extends StudentState {
  final List<dynamic> notices;

  ClassNoticesLoaded(this.notices);

  @override
  List<Object?> get props => [notices];
}

class ClassNoticesFailure extends StudentState {
  final String message;

  ClassNoticesFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceLoading extends StudentState {}

class AttendanceLoaded extends StudentState {
  final List<dynamic> attendance;

  AttendanceLoaded(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class AttendanceFailure extends StudentState {
  final String message;

  AttendanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SavedStudentsLoaded extends StudentState {
  final List<dynamic> savedStudents;
  SavedStudentsLoaded(this.savedStudents);

  @override
  List<Object?> get props => [savedStudents];
}

class AssignmentsLoading extends StudentState {}

class AssignmentsLoaded extends StudentState {
  final List<dynamic> assignments;
  AssignmentsLoaded(this.assignments);

  @override
  List<Object?> get props => [assignments];
}

class AssignmentsFailure extends StudentState {
  final String message;
  AssignmentsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class FeesLoading extends StudentState {}

class FeesLoaded extends StudentState {
  final List<dynamic> fees;
  FeesLoaded(this.fees);

  @override
  List<Object?> get props => [fees];
}

class FeesFailure extends StudentState {
  final String message;
  FeesFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LeavesLoading extends StudentState {}

class LeavesLoaded extends StudentState {
  final List<LeaveModel> leaves;
  LeavesLoaded(this.leaves);

  @override
  List<Object?> get props => [leaves];
}

class LeavesFailure extends StudentState {
  final String message;
  LeavesFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveApplying extends StudentState {}

class LeaveApplySuccess extends StudentState {
  final String message;
  LeaveApplySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveApplyFailure extends StudentState {
  final String message;
  LeaveApplyFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamsLoading extends StudentState {}

class ExamsLoaded extends StudentState {
  final List<ExamModel> exams;
  ExamsLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

class ExamsFailure extends StudentState {
  final String message;
  ExamsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkDetailsLoading extends StudentState {}

class MarkDetailsLoaded extends StudentState {
  final List<MarkDetailModel> details;
  MarkDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class MarkDetailsFailure extends StudentState {
  final String message;
  MarkDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordUpdateSaving extends StudentState {}

class PasswordUpdateSuccess extends StudentState {
  final String message;
  PasswordUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordUpdateFailure extends StudentState {
  final String message;
  PasswordUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class MessagesLoading extends StudentState {}

class MessagesLoaded extends StudentState {
  final List<dynamic> messages;
  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessagesFailure extends StudentState {
  final String message;
  MessagesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
