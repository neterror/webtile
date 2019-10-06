import 'dart:async';
import 'dart:html';
import 'package:dartleaf/dartleaf.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'vehicle_path.dart';
import 'bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:webtile38/src/gen/tile38.pb.dart' as pb;

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
class RouteSimulatorComponent implements OnDestroy {
  final _markers = [];
  final _polyline = Polyline(
      [],
      PolylineOptions()
        ..color = "black"
        ..dashArray = "5");
  String newPathName = "";
  String newGroupName = "";
  String newVehicleId = "";
  int selectedRoute = -1;
  final List<VehiclePath> paths;
  final Tile38Proto _protocol;

  StreamSubscription _subscription;
  RouteSimulatorComponent(DataStore store, this._protocol)
      : paths = store.routeSim {
    _subscription = _protocol.received.listen(_onReceived);
  }

  @override
  ngOnDestroy() {
    _subscription.cancel();
  }

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
    selectedRoute = index;
    _finishPath();
    _polyline.setLatLngs(path.points);
    _polyline.addTo(osm.map);
  }

  void onPlayPath(VehiclePath path) async {
    var pos = LatLng(path.points.first.lat, path.points.first.lng);
    final marker = Circle(
        pos,
        CircleOptions()
          ..radius = 90
          ..color = "black");
    final sub =
        Stream.periodic(Duration(milliseconds: 100), (x) => x).listen((i) {
      marker.setRadius(((i % 10) * 5).toDouble());
    });

    marker.addTo(osm.map);
    final stream = Stream.periodic(Duration(seconds: 2), (x) => x);

    await for (var i in stream) {
      if (i == path.points.length) {
        await sub.cancel();
        break;
      }
      pos = LatLng(path.points[i].lat, path.points[i].lng);
      marker.setLatLng(pos);
      _reportPosition(path, i);
    }
    print("stopping the simulator");

    marker.remove();
  }

  void _reportPosition(VehiclePath path, int pos) {
    final cmd = pb.SetObj()
      ..group = path.group
      ..object = path.vehicleId
      ..area = pb.Area();
    cmd.area.point = pb.Point();
    var c = pb.LatLng()
      ..lat = path.points[pos].lat
      ..lng = path.points[pos].lng;
    cmd.area.point.center = c;
    cmd.area.point.radius = 0;

    final packet = pb.Packet()..setObj = cmd;
    _protocol.send(packet);
  }

  void _onReceived(dynamic packet) {
    if (packet is! pb.Packet) return;
    switch (packet.whichData()) {
      case pb.Packet_Data.geofenceEvent:
        print("geofence event: ${packet.geofenceEvent}");
        break;
      default:
    }
  }
}
