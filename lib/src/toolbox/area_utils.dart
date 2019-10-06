import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:dartleaf/dartleaf.dart' as ll;
import 'package:webtile38/src/gen/tile38.pb.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';

class AreaUtils {
  final OpenStreetMap _osm;
  AreaUtils(this._osm);

  ll.Path circleFromArea(Area area,
      {bool focus = false, double focusZoom = 14}) {
    final p = area.point;
    var center = ll.LatLng(p.center.lat, p.center.lng);
    var result = ll.Circle(center, ll.CircleOptions(radius: p.radius));
    if (focus) _osm.map.setView(center, focusZoom);
    result.addTo(_osm.map);
    return result;
  }

  ll.Circle circleFromPoint(dynamic point,
      {@required double radius, String color}) {
    //  Expected a value of type 'JSObject<circle>', but got one of type 'NativeJavaScriptObject'
    //the point may come from javascript, in which case its type is NativeJavaScriptObject
    //copy to new object to avoid error runtime exceptions
    var pos = ll.LatLng(point.lat, point.lng);
    var options = ll.CircleOptions()..radius = radius;
    if (color is String) options.color = color;
    final marker = ll.Circle(pos, options);
    marker.addTo(_osm.map);
    return marker;
  }

  ll.Path polygon(Area area, {bool focus = false, double focusZoom = 14}) {
    final json = jsonDecode(area.json.value);
    var coordinates = [];
    var list = json["geometry"]["coordinates"];
    if (list.isEmpty) {
      print("empty polygon coordinates");
      return null;
    }
    if (list[0][0] is List) {
      //LineSegment is list of pairs, Polyline is list of list of pairs ... !@#
      list = list[0];
    }

    for (var pos in list) {
      var latlng = ll.LatLng(pos[1], pos[0]);
      coordinates.add(latlng);
    }
    final result = ll.Polygon(coordinates);
    result.addTo(_osm.map);
    var center = result.getCenter();
    if (focus) _osm.map.setView(center, focusZoom);
    return result;
  }
}
