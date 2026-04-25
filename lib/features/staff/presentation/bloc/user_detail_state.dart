import 'package:equatable/equatable.dart';

abstract class UserDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailUpdateSuccess extends UserDetailState {
  final String message;
  UserDetailUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserDetailUpdateFailure extends UserDetailState {
  final String message;
  UserDetailUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
