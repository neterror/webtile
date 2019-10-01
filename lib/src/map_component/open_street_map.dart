import 'dart:html';
import 'package:angular/angular.dart';
import 'package:dartleaf/dartleaf.dart';

@Component(
    selector: 'open-street-map',
    styleUrls: ['open_street_map.css'],
    templateUrl: 'open_street_map.html',
    directives: [NgStyle])
class OpenStreetMap implements OnInit, AfterViewInit {
  LeafletMap _map;

  LeafletMap get map => _map;
  @override
  void ngOnInit() {}

  @override
  void ngAfterViewInit() {
    _show("map-placeholder");
  }

  @Input()
  Map<String, String> size;

  void _show(String elementId) {
    _map = LeafletMap("map-placeholder");
    var options = TileLayerOptions()
      ..attribution =
          'Map data &copy, <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
      ..maxZoom = 20;

    TileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', options)
        .addTo(_map);

    _map.setView(LatLng(43.21047, 27.93470), 14);

    // disable the default right click - use it as cancel last poitn
    var div = querySelector("#$elementId");
    div.addEventListener('contextmenu', (Event e) {
      e.preventDefault();
    });
  }

  void setView({double lat, double lng, double zoom = 10}) =>
      _map.setView(LatLng(lat, lng), zoom);
}
