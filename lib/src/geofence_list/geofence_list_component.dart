import 'dart:convert';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'package:webtile38/src/toolbox/fence_toolbox.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:dartleaf/dartleaf.dart' as ll;

@Component(
    selector: 'geofence-list',
    templateUrl: 'geofence_list_component.html',
    styleUrls: [
      'geofence_list_component.css'
    ],
    pipes: [
      BlocPipe
    ],
    providers: [
      materialProviders
    ],
    directives: [
      coreDirectives,
      MaterialAutoSuggestInputComponent,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialSelectItemComponent,
      MaterialButtonComponent,
      FenceToolboxComponent,
      MaterialFabComponent,
      MaterialIconComponent
    ])
class GeofenceListComponent with Dragging implements OnInit, OnDestroy {
  Tile38Proto _protocol;
  final List<String> groups;

  GeofenceListComponent(this._protocol, DataStore store)
      : groups = store.fleet.map((x) => x.name).toList();


  StreamSubscription _sub;
  List<Hook> hooks;
  int selectedIdx;
  ll.Path _selected;

  @Input()
  OpenStreetMap map;

  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance

  void onHookCreated(CreateHook hook) {
    fenceToolboxBloc.dispatch(HideToolEvent());
    if (hook is CreateHook) {
      final packet = Packet()..createHook = hook;
      _protocol.send(packet);
    }
  }

  @override
  void ngOnInit() {
    _sub = _protocol.received.listen(_onReceived);
    initDragging(container: "#map-editor");
    makeDraggable("#fence", fenceToolboxBloc);
  }

  @override
  void ngOnDestroy() {
    _sub.cancel();
    _selected?.remove();
    fenceToolboxBloc.dispose();
  }

  void _onReceived(dynamic data) {
    if (data is! Packet) return;
    Packet packet = data;
    switch (packet.whichData()) {
      case Packet_Data.hooks:
        hooks = packet.hooks.items;
        break;
      case Packet_Data.status:
        if (!packet.status.success) {
          print("error: ${packet.status.message}");
        } else {
          print("operation complete");
        }
        break;
      default:
    }
  }

  ll.Path _circle(Area area) {
    final p = area.point;
    var center = ll.LatLng(p.center.lat, p.center.lng);
    var result = ll.Circle(center, ll.CircleOptions(radius: p.radius));
    map.map.setView(center, 14);
    result.addTo(map.map);
    return result;
  }

  ll.Path _polygon(Area area) {
    final json = jsonDecode(area.json.value);
    var coordinates = [];
    for (var pos in json["geometry"]["coordinates"]) {
      var latlng = ll.LatLng(pos[1], pos[0]);
      coordinates.add(latlng);
    }
    ll.Polygon result = ll.Polygon(coordinates);
    result.addTo(map.map);
    var center = result.getCenter();
    map.map.setView(center, 14);
    return result;
  }

  void selected(Hook hook, int index) {
    selectedIdx = index;
    _selected?.remove();
    _selected = (hook.area.whichData() == Area_Data.point)
        ? _circle(hook.area)
        : _polygon(hook.area);
  }

  void addNewHook() {
    fenceToolboxBloc.dispatch(ShowToolEvent([100, 100]));
  }

  void getHookList(String filter) {
    if (filter is! String) {
      filter = "";
    };

    final request = GetHooks();
    request.pattern = filter;
    print("sending tho hook pattern: $filter");
    final packet = Packet()..getHooks = request;
    _protocol.send(packet);
  }
}
