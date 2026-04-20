import 'package:equatable/equatable.dart';

abstract class StaffUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffUploadInitial extends StaffUploadState {}

class StaffUploadLoading extends StaffUploadState {}

class StaffUploadSuccess extends StaffUploadState {
  final String message;
  StaffUploadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StaffUploadFailure extends StaffUploadState {
  final String message;
  StaffUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
