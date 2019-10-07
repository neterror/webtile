import 'dart:js';

import 'package:dartleaf/dartleaf.dart' as m;
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'draw.dart';
import 'circle_shape.dart';

class DrawCircle implements Draw {
  final m.LeafletMap _map;
  String _label;
  m.LatLng _centerCoord;
  m.Point _centerPoint;
  m.Circle _circleMarker;
  m.Tooltip _labelTooltip;
  AreaBloc _bloc;

  set label(String text) {
    _label = text;
    _labelTooltip?.setTooltipContent(_label);
  }

  DrawCircle(this._map, this._bloc, [this._label]);

  @override
  set active(bool draw) {
    if (draw) {
      _map.dragging.disable();
      _map.on(m.E.mousedown, allowInterop(_mouseDown));
      _map.on(m.E.mousemove, allowInterop(_drawCircle));
    } else {
      _map.off(m.E.mousedown);
      _map.off(m.E.mousemove);
      _map.dragging.enable();
    }
  }

  void _mouseDown(m.LeafletMouseEvent e) =>
      _circleMarker != null ? _drawCircleEnd(e) : _drawCircleStart(e);

  void _drawCircleStart(m.LeafletMouseEvent e) {
    _centerCoord = e.latlng;
    _centerPoint = e.layerPoint;
    var options = m.CircleOptions()
      ..stroke = true
      ..color = 'black'
      ..fillColor = '#cccccc'
      ..fillOpacity = 0.8
      ..radius = 1;

    _circleMarker = m.Circle(_centerCoord, options);

    _labelTooltip = _circleMarker.bindTooltip(
        _label,
        m.TooltipOptions()
          ..opacity = 0.8
          ..direction = 'center'
          ..className = 'geofence-labels'
          ..permanent = true
          ..interactive = false);

    _circleMarker.addTo(_map);
  }

  void _drawCircleEnd(m.LeafletMouseEvent e) {
    var shape = CircleShape(_map, _label, _circleMarker, _centerCoord, _bloc);
    _bloc.dispatch(AreaCreatedEvent(shape));
    _centerCoord = null;
    _centerPoint = null;
    _circleMarker = null;
  }

  void _drawCircle(m.LeafletMouseEvent e) {
    if (_centerPoint == null) return;
    var p = e.layerPoint;
    double radius = p.distanceTo(_centerPoint);

    //the Circle radius is in meters, mouse event measure the offset in pixels
    //At large zoom level small pixel changes should affect large territory.
    //There is no need for high precision, the constants bellow are set to give good sense of control to moderately larger areas
    //To select city areas or larges use the polygon tool
    double correction = (17 - _map.getZoom()) * 2;
    if (correction > 0) radius *= correction;

    var text = """
      $_label  <br>
      <small>r=${radius.toInt()} m </small>
    """;
    _labelTooltip?.setTooltipContent(text);
    _circleMarker.setRadius(radius);

    var updateMsg =
        "lat: ${_centerCoord.lat.toStringAsFixed(3)} lng: ${_centerCoord.lng.toStringAsFixed(3)} radius: ${radius.toStringAsFixed(0)} m";
    _bloc.dispatch(AreaDrawEvent(updateMsg));
  }
}
