import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import './bloc.dart';
import 'package:webtile38/src/sketch_maker/draw.dart';
import 'package:webtile38/src/sketch_maker/draw_circle.dart';
import 'package:webtile38/src/sketch_maker/draw_polygon.dart';

class SketchBloc extends Bloc<OptionsEvent, DrawingState> {
  OpenStreetMap map;
  String label;
  Draw _draw;
  final AreaBloc _areaBloc;

  SketchBloc(this._areaBloc);
  @override
  DrawingState get initialState => InactiveDrawingState();

  @override
  Stream<DrawingState> mapEventToState(
    OptionsEvent event,
  ) async* {
    _draw?.active = false;
    _draw = null;
    map.style["cursor"] = "pointer";

    DrawingState result = InactiveDrawingState();

    if (event is PolygonOptionEvent) {
      _draw = DrawPolygon(map.map, _areaBloc, event.label);
    } else if (event is CircleOptionEvent) {
      _draw = DrawCircle(map.map, _areaBloc, event.label);
    }

    if (_draw is Draw) {
      _draw.active = true;
      result = ActiveDrawingState(_draw);
      map.style["cursor"] = "crosshair";
    }
    yield result;
  }
}
