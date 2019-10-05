import 'dart:html';
import 'package:dartleaf/dartleaf.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'vehicle_path.dart';
import 'bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';

@Component(
    selector: 'route-simulator',
    templateUrl: 'route_simulator_component.html',
    pipes: [
      BlocPipe
    ],
    providers: [
      materialProviders
    ],
    directives: [
      formDirectives,
      coreDirectives,
      MaterialSelectItemComponent,
      MaterialListComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialButtonComponent,
      ModalComponent,
      MaterialDialogComponent,
      MaterialInputComponent,
      materialInputDirectives,
      AutoFocusDirective,
      OpenStreetMap,
    ],
    styleUrls: [
      'route_simulator_component.css'
    ])
class RouteSimulatorComponent {
  final _markers = [];
  final _polyline = Polyline([]);
  String newPathName = "";
  String newGroupName = "";
  String newVehicleId = "";
  final List<VehiclePath> paths;

  RouteSimulatorComponent(DataStore store) : paths = store.routeSim;

  @Input()
  PathmakerBloc bloc;

  @Input()
  PathmakerState state;

  @ViewChild(OpenStreetMap)
  OpenStreetMap osm;

  bool get activeDraw => state is! PathmakerInactiveState;
  bool get reportingPos => state is PathmakerPosState;
  bool get readPathName => state is PathmakerPathNameState;

  void _attachEvents() {
    osm.map.on(E.mousedown, _mouseDown);
    osm.map.on(E.mousemove,
        (e) => bloc.dispatch(PathmakerPosEvent(e.latlng.lat, e.latlng.lng)));
  }

  void _detachEvents() {
    osm.map.off(E.mousedown);
    osm.map.off(E.mousemove);
  }

  void _mouseDown(LeafletMouseEvent e) {
    bool leftMouseBtn = ((e.originalEvent as MouseEvent).button == 0);
    if (leftMouseBtn) {
      var marker = Circle(e.latlng, CircleOptions()..radius = 20);
      marker.addTo(osm.map);
      _markers.add(marker);
      _polyline.addLatLng(e.latlng);
    } else {
      var points = _polyline.getLatLngs();
      if (points.isNotEmpty) {
        points.removeLast();
        _polyline.setLatLngs(points);
        _markers.last.remove();
        _markers.removeLast();
      }
    }
  }

  void _finishPath() {
    _polyline.remove();
    _polyline.setLatLngs([]);
    _markers.forEach((x) => x.remove());

    _detachEvents();
    bloc.dispatch(PathmakerInactiveEvent());
  }

  void onNewPath() {
    _finishPath();
    _attachEvents();
    _polyline.addTo(osm.map);
    bloc.dispatch(PathmakerActiveEvent());
  }

  void onPathOk() {
    if (_markers.isEmpty) {
      _finishPath();
    } else {
      bloc.dispatch(PathmakerPathNameEvent());
    }
  }

  void onPathComplete() {
    if (newPathName is! String || newPathName.isEmpty) {
      _finishPath();
      return;
    }
    var path = VehiclePath(
        newPathName, newGroupName, newVehicleId, _polyline.getLatLngs());
    print("adding path ${path.points}");
    paths.add(path);
    _finishPath();
  }

  void onPathCancel() {
    _finishPath();
  }

  void onSelectedPath(VehiclePath path, int index) {
    _finishPath();
    _polyline.setLatLngs(path.points);
    _polyline.addTo(osm.map);
    print("selected path visualized");
  }

  void onPlayPath(VehiclePath path) async {
    var pos = LatLng(path.points.first.lat, path.points.first.lng);
    var marker = Circle(pos, CircleOptions()..radius = 90);
    marker.addTo(osm.map);
    var stream = Stream.periodic(Duration(seconds: 1), (x) => x);

    await for (var i in stream) {
      if (i == path.points.length) {
        break;
      }
      pos = LatLng(path.points[i].lat, path.points[i].lng);
      marker.setLatLng(pos);
    }
    print("stopping the simulator");
    marker.remove();
  }
}
