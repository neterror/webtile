import 'package:dartleaf/dartleaf.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'shape.dart';

class CircleShape extends Shape {
  final LeafletMap _map;
  CircleMarker _marker;
  LatLng _center;
  final Circle _circle;

  CircleShape(this._map, AreaBloc areaBloc, label, this._circle, this._center)
      : super(_circle, areaBloc) {
    _createLabel(label);
  }

  @override
  GeoJson toGeoJson() => _circle.toGeoJSON();

  String get description =>
      "POINT ${_center.lat.toStringAsFixed(5)} ${_center.lng.toStringAsFixed(5)} ${_circle.getRadius().toStringAsFixed(0)}";

  @override
  set label(String text) {
    _marker.setTooltipContent(text);
  }

  _createLabel(String text) {
    var tooltipOptions = TooltipOptions()
      ..className = "geofence-labels"
      ..direction = 'center'
      ..permanent = true;

    var transparentOptions = CircleOptions()
      ..opacity = 0
      ..fillOpacity = 0;

    _marker = CircleMarker(_center, transparentOptions);
    _marker.bindTooltip(text, tooltipOptions);
    _marker.addTo(_map);
  }

  dispose() {
    _circle?.remove();
  }
}
