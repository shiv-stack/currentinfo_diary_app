import 'package:equatable/equatable.dart';

abstract class QueryEvent extends Equatable {
  const QueryEvent();

  @override
  List<Object> get props => [];
}

class SendQueryEvent extends QueryEvent {
  final String schoolCode;
  final String title;
  final String name;
  final String mobile;
  final String message;

  const SendQueryEvent({
    required this.schoolCode,
    required this.title,
    required this.name,
    required this.mobile,
    required this.message,
  });

  @override
  List<Object> get props => [schoolCode, title, name, mobile, message];
}
