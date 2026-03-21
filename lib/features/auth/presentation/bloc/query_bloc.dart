import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_query_usecase.dart';
import 'query_event.dart';
import 'query_state.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final SendQueryUseCase sendQueryUseCase;

  QueryBloc({required this.sendQueryUseCase}) : super(QueryInitial()) {
    on<SendQueryEvent>(_onSendQuery);
  }

  Future<void> _onSendQuery(
    SendQueryEvent event,
    Emitter<QueryState> emit,
  ) async {
    emit(QueryLoading());

    final result = await sendQueryUseCase(
      schoolCode: event.schoolCode,
      title: event.title,
      name: event.name,
      mobile: event.mobile,
      message: event.message,
    );

    result.fold(
      (failure) => emit(QueryError(failure.message)),
      (_) => emit(QuerySuccess()),
    );
  }
}
