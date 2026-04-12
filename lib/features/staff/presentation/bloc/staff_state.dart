import 'package:equatable/equatable.dart';
import '../../domain/entities/staff.dart';

abstract class StaffState extends Equatable {
  @override
  List<Object> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoginSuccess extends StaffState {
  final Staff staff;

  StaffLoginSuccess(this.staff);

  @override
  List<Object> get props => [staff];
}

class StaffLoginFailure extends StaffState {
  final String message;

  StaffLoginFailure(this.message);

  @override
  List<Object> get props => [message];
}
