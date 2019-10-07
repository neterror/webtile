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
import 'package:webtile38/src/toolbox/area_utils.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:dartleaf/dartleaf.dart' as ll;
import 'package:angular_components/laminate/components/modal/modal.dart';

class _LastStatus {
  bool show;
  bool success;
  String message;
}

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
      NgModel,
      MaterialAutoSuggestInputComponent,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialSelectItemComponent,
      MaterialButtonComponent,
      FenceToolboxComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialDialogComponent,
      AutoDismissDirective,
      ModalComponent
    ])
class GeofenceListComponent with Dragging implements AfterViewInit, OnDestroy {
  Tile38Proto _protocol;
  final List<String> groups;
  String enteredFilter;
  String selectedGroup;
  int selectedGroupIdx;

  final lastStatus = _LastStatus();
  GeofenceListComponent(this._protocol, DataStore store)
      : groups = store.fleet.map((x) => x.name).toList();

  StreamSubscription _sub;
  List<Hook> hooks;
  int selectedHookIdx = -1;
  ll.Path _selectedPath;

  @Input()
  OpenStreetMap osm;

  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance

  void onHookCreated(CreateHook hook) {
    fenceToolboxBloc.dispatch(HideToolEvent());
    _selectedPath?.remove();
    if (hook is CreateHook) {
      final packet = Packet()..createHook = hook;
      _protocol.send(packet);
    }
  }

  @override
  void ngAfterViewInit() {
    _sub = _protocol.received.listen(_onReceived);
    initDragging(container: "#map-editor");
    makeDraggable("#fence", fenceToolboxBloc);
  }

  @override
  void ngOnDestroy() {
    _sub.cancel();
    _selectedPath?.remove();
    fenceToolboxBloc.dispose();
  }

  void _onReceived(dynamic data) {
    if (data is! Packet) return;
    Packet packet = data;
    switch (packet.whichData()) {
      case Packet_Data.hookList:
        hooks = packet.hookList.items;
        break;
      case Packet_Data.status:
        if (packet.status.success) {
          getHookList("$selectedGroup*");
        } else {
          lastStatus.success = packet.status.success;
          lastStatus.message = packet.status.message;
          lastStatus.show = true;
        }

        break;
      default:
    }
  }

  void onSelectedHook(Hook hook, int index) {
    selectedHookIdx = index;
    _selectedPath?.remove();
    final area = AreaUtils(osm);
    _selectedPath = (hook.area.whichData() == Area_Data.point)
        ? area.circleFromArea(hook.area, focus: true, focusZoom: 14)
        : area.polygon(hook.area, focus: true, focusZoom: 14);
  }

  void onSelectGroup(String group, int index) {
    selectedGroup = group;
    selectedGroupIdx = index;
    getHookList("$group*");
  }

  void addNewHook() {
    fenceToolboxBloc.dispatch(ShowToolEvent([180, 350]));
  }

  void delHook() {
    if (selectedHookIdx == -1) return;
    final request = DelHook();
    request.pattern = hooks[selectedHookIdx].name;
    print("Deleting hook $request.pattern");
    final packet = Packet()..delHook = request;
    _protocol.send(packet);
  }

  void getHookList(String filter) {
    selectedHookIdx = -1;
    _selectedPath?.remove();

    if (filter is! String) filter = "";

    final request = GetHooks();
    request.pattern = filter;
    final packet = Packet()..getHooks = request;
    _protocol.send(packet);
  }

  void onStatusDismissed() {
    lastStatus.show = false;
    if (lastStatus.success) {
      getHookList(enteredFilter);
    }
  }
}
