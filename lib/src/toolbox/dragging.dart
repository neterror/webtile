import 'package:meta/meta.dart';
import 'dart:html';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';

mixin Dragging {
  final _dragStart = <int>[0, 0]; //point to mark the beginning of the dragging
  ToolboxBloc activeToolbox;

  initDragging({@required String container}) {
    var element = document.querySelector(container);
    element?.onDragEnd?.listen(_dragEnd);
  }

  void makeDraggable(String selector, ToolboxBloc bloc) {
    var element = document.querySelector(selector);
    element?.onDragStart?.listen((MouseEvent e) {
      _dragStart[0] = e.client.x;
      _dragStart[1] = e.client.y;
      activeToolbox = bloc;
    });
  }

  void _dragEnd(MouseEvent e) {
    int offsetX = e.client.x - _dragStart[0];
    int offsetY = e.client.y - _dragStart[1];
    activeToolbox.dispatch(MoveToolEvent(
        [offsetX, offsetY])); //todo - see the bloc of the dragged one
  }
}
