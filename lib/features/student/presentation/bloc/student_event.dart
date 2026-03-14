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
