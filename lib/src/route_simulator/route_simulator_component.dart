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
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'vehicle_path.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:webtile38/src/gen/tile38.pb.dart' as pb;
import 'package:webtile38/src/toolbox/area_utils.dart';

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
class RouteSimulatorComponent implements OnInit, OnDestroy {
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
  List<pb.Hook> _hooks;
  final DataStore _dataStore;

  StreamSubscription _subscription;
  RouteSimulatorComponent(this._dataStore, this._protocol)
      : paths = _dataStore.routeSim  {
    _subscription = _protocol.received.listen(_onReceived);
  }

  @Input()
  bool initMap = true;

  void showMap() => osm.show();

  @override
  void ngOnInit() {
    final request = pb.GetHooks()..pattern = "*";
    final packet = pb.Packet()..getHooks = request;
    _protocol.send(packet);
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
    osm.on(E.mousedown, _mouseDown);
    osm.on(E.mousemove,
        (e) => bloc.dispatch(PathmakerPosEvent(e.latlng.lat, e.latlng.lng)));
  }

  void _detachEvents() {
    osm.map.off(E.mousedown);
    osm.map.off(E.mousemove);
  }

  void _mouseDown(LeafletMouseEvent e) {
    bool leftMouseBtn = ((e.originalEvent as MouseEvent).button == 0);
    if (leftMouseBtn) {
      var a = AreaUtils(osm);
      var marker = a.circleFromPoint(e.latlng, radius: 20, color: "blue");
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
    _dataStore.save();
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

  Stream<int> _timeSeq(int milliseconds) =>
      Stream.periodic(Duration(milliseconds: milliseconds), (x) => x);

  void onPauseEvent(path) {
    paths.elementAt(paths.indexOf(path)).running = false; 
  }

  void onLoopPath(VehiclePath path) {
    if (paths.contains(path)) {
      VehiclePath curPath = paths.elementAt(paths.indexOf(path));
      if (curPath.running) {
        return;
      } else {
        onPlayPath(curPath, true);
      }
    }
  }

  void onPlayPath(VehiclePath path, bool loop) async {
    var p = path.points.first;
    var a = AreaUtils(osm);
    var marker = a.circleFromPoint(p, radius: 20, color: "black");
    final sub = _timeSeq(50)
        .listen((i) => marker.setRadius(((i * 2) % 20 + 20).toDouble()));
    path.running = true;
    marker.addTo(osm.map);
    await for (var i in _timeSeq(1000)) {
      if (!path.running) {
          break;
      }
      if (i == path.points.length) {
        
        if (!loop) {
          await sub.cancel();
          path.running = false;
          break;
        }
      }
      var pos = LatLng(path.points[i % path.points.length].lat,
                       path.points[i % path.points.length].lng);
      marker.setLatLng(pos);
      _reportPosition(path, i % path.points.length);
    }
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
        _geofenceEvent(packet.geofenceEvent);
        break;
      case pb.Packet_Data.hookList:
        _hooks = packet.hookList.items;
        break;
      default:
    }
  }

  void _geofenceEvent(pb.GeofenceEvent e) {
    print("received geofence event: ${e}");
    var active = _hooks.firstWhere((x) => x.name == e.hook);
    _showArea(active.area);
  }

  void _showArea(pb.Area area) async {
    var path = _createPath(area);
    final options = PathOptions();
    options.opacity = 1.0;
    options.stroke = true;
    await for (var i in _timeSeq(100)) {
      options.opacity = 1 - (0.1 * i);
      path.setStyle(options);
      if (i >= 10) break;
    }
    path.remove();
  }

  Path _createPath(pb.Area area) {
    final a = AreaUtils(osm);
    return (area.whichData() == pb.Area_Data.point)
        ? a.circleFromArea(area)
        : a.polygon(area, stroke: true);
  }
}
