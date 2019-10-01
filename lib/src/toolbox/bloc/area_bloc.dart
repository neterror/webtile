import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:webtile38/src/sketch_maker/shape.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  List<Shape> shapes;

  @override
  AreaState get initialState => InitialAreaState();

  @override
  Stream<AreaState> mapEventToState(
    AreaEvent event,
  ) async* {
    if (event is AreaCreatedEvent) {
      yield AreaCreatedState(event.shape);
    } else if (event is AreaDrawEvent) {
      yield AreaDrawInProgress(event.message);
    } else {
      yield initialState;
    }
  }
}
