import 'package:dartleaf/dartleaf.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';

class Shape {
  static const String fillColor = "#aaaaaa";
  static const String lineColor = "#888888";

  AreaBloc _areaBloc;

  final Path _path;
  bool _hovering = false;
  bool _selectMode = false;
  set selectMode(bool value) {
    _selectMode = value;
    if (_selectMode) {
      _attachEvents();
    } else {
      _detachEvents();
    }
  }

  Shape(this._path, [this._areaBloc]);

  removeFromMap() => _path.remove();

  set label(String value) {
    print("not implemented");
  }

  GeoJson toGeoJson() => null;
  String get description => null;

  void dispose() {}

  void _attachEvents() {
    _path.on(E.mouseover, (LeafletMouseEvent e) {
      _hovering = true;
      _path.setStyle(PathOptions(
          fill: true,
          fillColor: fillColor,
          fillOpacity: 0.8,
          color: lineColor));
    });

    _path.on(E.mouseout, (LeafletMouseEvent e) {
      _hovering = false;
      _path.setStyle(PathOptions(
          fill: true,
          fillColor: fillColor,
          fillOpacity: 0.4,
          color: lineColor));
    });

    _path.on(E.mousedown, (LeafletMouseEvent e) {
      if (_hovering) {
        _areaBloc?.dispatch(AreaSelected());
      }
    });
  }

  void _detachEvents() {
    _path.off(E.mouseover);
    _path.off(E.mouseout);
    _path.off(E.mousedown);
  }
}
