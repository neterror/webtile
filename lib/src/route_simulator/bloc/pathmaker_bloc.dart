import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class PathmakerBloc extends Bloc<PathmakerEvent, PathmakerState> {
  @override
  PathmakerState get initialState => PathmakerInactiveState();

  @override
  Stream<PathmakerState> mapEventToState(
    PathmakerEvent event,
  ) async* {
    print("the event is $event");
    if (event is PathmakerActiveEvent) {
      yield PathmakerActiveState();
    } else if (event is PathmakerInactiveEvent) {
      yield PathmakerInactiveState();
    } else if (event is PathmakerPosEvent) {
      yield PathmakerPosState(event.lat, event.lng);
    }
  }
}
