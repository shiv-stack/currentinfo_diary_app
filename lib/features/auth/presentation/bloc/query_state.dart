import 'package:equatable/equatable.dart';

abstract class QueryState extends Equatable {
  const QueryState();

  @override
  List<Object> get props => [];
}

class QueryInitial extends QueryState {}

class QueryLoading extends QueryState {}

class QuerySuccess extends QueryState {}

class QueryError extends QueryState {
  final String message;

  const QueryError(this.message);

  @override
  List<Object> get props => [message];
}
