import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:webtile38/src/toolbox/bloc/toolbox_event.dart';
import 'package:webtile38/src/toolbox/bloc/toolbox_state.dart';

class ToolboxBloc extends Bloc<ToolboxEvent, ToolboxState> {
  List<int> _position;

  @override
  ToolboxState get initialState => InactiveToolboxState();

  @override
  Stream<ToolboxState> mapEventToState(ToolboxEvent event) async* {
    ToolboxState result;
    if (event is HideToolEvent) {
      result = InactiveToolboxState();
    } else if (event is ShowToolEvent) {
      _position = event.position;
      result = ActiveToolboxState(_position);
    } else if (event is MoveToolEvent) {
      _position[0] += event.position[0];
      _position[1] += event.position[1];
      result = ActiveToolboxState(_position);
    }

    yield result;
  }
}
