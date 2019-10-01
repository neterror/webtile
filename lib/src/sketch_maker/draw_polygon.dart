import 'dart:html';
import 'package:dartleaf/dartleaf.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'draw.dart';
import 'shape.dart';
import 'polygon_shape.dart';

/// Left click adds a point, right click removes point
class DrawPolygon implements Draw {
  final LeafletMap _map;
  CircleMarker _firstMark;
  String _label;
  AreaBloc _bloc;

  DrawPolygon(this._map, this._bloc, [this._label]);

  set label(String text) {
    _label = text;
  }

  Polyline _polyline = Polyline([]);
  Polyline _dashLine = Polyline([]);

  final _points = [];
  bool _ready = false;

  final _normalNode = CircleOptions()
    ..radius = 7
    ..fillColor = Shape.fillColor
    ..color = "#000"
    ..weight = 1
    ..opacity = 1
    ..fillOpacity = 0.8;

  final _accentNode = CircleOptions()
    ..radius = 15
    ..fillColor = Shape.fillColor
    ..color = "#000"
    ..weight = 2
    ..opacity = 1
    ..fillOpacity = 0.9;

  @override
  set active(bool draw) {
    draw ? _activate() : _deactivate();
  }

  void _activate() {
    _map.dragging.disable();
    _map.on(E.mousedown, _buttonDown);
    _map.on(E.mousemove, _mouseMove);

    _polyline.setStyle(PathOptions(
        fill: true,
        fillColor: Shape.fillColor,
        fillOpacity: 0.4,
        color: Shape.lineColor));
    _polyline.addTo(_map);

    _dashLine.addTo(_map);
    _dashLine.setStyle(PolylineOptions()
      ..dashArray = "4"
      ..color = Shape.lineColor);
  }

  void _deactivate() {
    _map.dragging.enable();
    _map.off(E.mousedown);
    _map.off(E.mousemove);

    _polyline.remove();
    _dashLine.remove();
    for (var p in _points) {
      p.remove();
    }
  }

  _buttonDown(LeafletMouseEvent e) {
    MouseEvent mouse = e.originalEvent;
    if (mouse.button == 0) {
      //left mouse button
      _addPoint(e);
    } else {
      if (_points.isNotEmpty) _delPoint(e);
    }
  }

  _addPoint(LeafletMouseEvent e) {
    if (_points.isNotEmpty) {
      _points.last.unbindTooltip();
    }
    if (_ready) {
      _finish(_polyline);
    } else {
      var node = CircleMarker(e.latlng, _normalNode);
      node.bindTooltip("", TooltipOptions()..permanent = true);

      if (_firstMark == null) _firstMark = node;
      _points.add(node);
      _polyline.addLatLng(e.latlng);
      node.addTo(_map);
    }
  }

  _delPoint(LeafletMouseEvent e) {
    var last = _points.removeLast();
    last.remove(); //remove the marker from the layer

    if (_points.isEmpty) {
      _hideDashLine();
      _polyline.setLatLngs([]);
    } else {
      //build a list with the remaining points
      var remaining = _points.map((c) => c.getLatLng()).toList();
      _polyline.setLatLngs(remaining);
      _drawDashLine(e);
    }
  }

  _hideDashLine() {
    _dashLine.setLatLngs([]);
    _dashLine.redraw();
  }

  _drawDashLine(LeafletMouseEvent e) {
    var remaining = _points.map((c) => c.getLatLng()).toList();
    var last = _points.last.getLatLng();
    var line = [last, e.latlng];

    if (_points.isNotEmpty) {
      var distance = remaining.last.distanceTo(e.latlng);
      _points.last.setTooltipContent("${distance.toInt()} m");
    }
    _dashLine.setLatLngs(line);
    _dashLine.redraw();
  }

  _mouseMove(LeafletMouseEvent e) {
    if (_points.isEmpty) return;
    _drawDashLine(e);
    double distance = _firstMark.getLatLng().distanceTo(e.latlng);
    _ready = (distance < 30);
    if (_ready) {
      _firstMark.setStyle(_accentNode);
    } else {
      _firstMark.setStyle(_normalNode);
    }
  }

  _finish(Polyline polyline) {
    polyline.addLatLng(_firstMark.getLatLng());
    var shape = PolygonShape(_map, _bloc, _label, polyline);
    _bloc.dispatch(AreaCreatedEvent(shape));
    _reset();
  }

  _reset() {
    _hideDashLine();
    _points.forEach((x) => x.remove());
    _points.clear();
    _polyline = Polyline([]);
    _polyline.setStyle(PathOptions(
        fill: true, fillColor: Shape.fillColor, color: Shape.lineColor));
    _polyline.addTo(_map);
    _firstMark = null;
    _ready = false;
  }
}
