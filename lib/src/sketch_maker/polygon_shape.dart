import 'dart:convert';
import 'package:dartleaf/dartleaf.dart';
import 'package:webtile38/src/toolbox/bloc/area_bloc.dart';
import 'shape.dart';

class PolygonShape extends Shape {
  final LeafletMap _map;
  final Polyline _polyline;
  CircleMarker _marker;
  PolygonShape(this._map, String label, this._polyline, [AreaBloc bloc]) : super(_polyline, bloc) {
    _createLabel(label);
  }

  @override
  GeoJson toGeoJson() => _polyline.toGeoJSON(); 

  @override
  String get description {
    var obj = _polyline.toGeoJSON();
    var result = {"type": obj.type, "geometry": {
      "type": obj.geometry.type,
      "coordinates": obj.geometry.coordinates
    }};
    return jsonEncode(result);
  }

  @override
  set label(String text) {
    _marker.setTooltipContent(text);
  }

  _createLabel(String text) {
    var center = _polyline.getBounds().getCenter();
    var tooltipOptions = TooltipOptions()
      ..className = "geofence-labels"
      ..direction = 'center'
      ..permanent = true;

    var transparentOptions = CircleOptions()
      ..opacity = 0
      ..fillOpacity = 0;

    _marker = CircleMarker(center, transparentOptions);
    _marker.bindTooltip(text, tooltipOptions);
    _marker.addTo(_map);
  }

  dispose() {
    _polyline?.remove();
    _marker?.remove();
  }
}
