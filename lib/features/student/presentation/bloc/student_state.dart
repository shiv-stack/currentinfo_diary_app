import 'package:equatable/equatable.dart';
import '../../data/models/student_model.dart';

abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

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
