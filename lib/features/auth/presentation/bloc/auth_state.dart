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

  AuthSuccess({this.message = "Success", this.school, this.schoolCode});

  @override
  List<Object?> get props => [message, school, schoolCode];
}

class StudentAuthenticated extends AuthState {
  final StudentModel student;
  StudentAuthenticated(this.student);

  @override
  List<Object?> get props => [student];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
