import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StaffLoginSubmitted extends StaffEvent {
  final String schoolCode;
  final String name;
  final String uniqueCode;

  StaffLoginSubmitted({
    required this.schoolCode,
    required this.name,
    required this.uniqueCode,
  });

  @override
  List<Object> get props => [schoolCode, name, uniqueCode];
}
