import 'package:equatable/equatable.dart';
import '../../data/models/school_model.dart';
import '../../../student/data/models/student_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class NavigateToSchoolCode extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final SchoolModel? school;
  final String? schoolCode;
  final String? feesoftware;

  AuthSuccess({
    this.message = "Success",
    this.school,
    this.schoolCode,
    this.feesoftware,
  });

  @override
  List<Object?> get props => [message, school, schoolCode, feesoftware];
}

class StudentAuthenticated extends AuthState {
  final StudentModel student;
  final SchoolModel? school;

  StudentAuthenticated(this.student, {this.school});

  @override
  List<Object?> get props => [student, school];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
