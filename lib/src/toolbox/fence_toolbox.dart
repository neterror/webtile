import 'dart:async';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/sketch_maker/circle_shape.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';

class _Detect {
  Detection detection;
  bool selected = false;
  _Detect(this.detection);
}

@Component(
    selector: 'fence-toolbox',
    templateUrl: 'fence_toolbox.html',
    providers: [
      materialProviders,
    ],
    directives: [
      coreDirectives,
      NgModel,
      NgClass,
      NgStyle,
      MaterialToggleComponent,
      MaterialInputComponent,
      materialInputDirectives,
      MaterialAutoSuggestInputComponent,
      MaterialRadioComponent,
      MaterialRadioGroupComponent,
      MaterialButtonComponent,
      MaterialCheckboxComponent,
      MaterialIconComponent,
      ToolboxComponent
    ],
    pipes: [
      BlocPipe
    ],
    styleUrls: [
      'toolbox.css'
    ])
class FenceToolboxComponent with Dragging implements OnDestroy {
  final _streamCtrl = StreamController<CreateHook>();
  final Hook hook = Hook();
  final allCommands = Command.values.map((c) => c.name).toList();
  bool selectingArea = false;

  StreamSubscription _subscription;

  String areaText;
  final detectOptions = <_Detect>[
    _Detect(Detection.enter),
    _Detect(Detection.leave),
    _Detect(Detection.inside),
    _Detect(Detection.outside),
    _Detect(Detection.cross)
  ];

  @Output()
  Stream<CreateHook> get created => _streamCtrl.stream;

  /// the state (active, inactive, dragging) of the toolbox
  /// Controlled by the invoker bloc (geofence_list_component)
  @Input()
  ToolboxState state;

  /// the sketch toolbox dispatches events to the areas bloc
  final areasBloc = AreaBloc(); //final shapes processor

  SketchBloc drawingBloc;

  final List<String> groups;

  Area _makeArea(String text) {
    var area = Area();
    if (!text.startsWith("POINT")) {
      area.json = GeoJson()
        ..value = text; // text.replaceFirst("LineString", "Polygon");
    } else {
      final tokens = text.split(" ");
      area.point = Point()..center = LatLng();
      area.point.center.lat = double.parse(tokens[1]);
      area.point.center.lng = double.parse(tokens[2]);
      area.point.radius = double.parse(tokens[3]);
    }
    return area;
  }

  OpenStreetMap _map;

  @Input()
  set map(OpenStreetMap value) {
    _map = value;
    _subscription = areasBloc.state.listen((AreaState s) {
      if (s is AreaCreatedState) {
        areaText = (s.shape is CircleShape) ? "circle area" : "polygon area";
        hook.area = _makeArea(s.shape.description);
        s.shape.dispose();
      } else if (s is AreaDrawInProgress) {
        areaText = s.message;
      }
    });
  }

  FenceToolboxComponent(DataStore store)
      : groups = store.fleet.map((x) => x.name).toList() {
    initDragging(container: "#map-editor");
  }

  @override
  void ngOnDestroy() {
    drawingBloc?.dispose();
    areasBloc.dispose();
    _subscription?.cancel();
  }

  void onSelectArea(bool enabled) {
    selectingArea = enabled;
    if (enabled) {
      drawingBloc = SketchBloc(areasBloc);
      drawingBloc.map = _map;
      drawingBloc?.dispatch(CircleOptionEvent(label: ""));
    } else {
      drawingBloc?.dispatch(EndOptionEvent());
      drawingBloc?.dispose();
      drawingBloc = null;
    }
  }

  void onToolChange(String tool) {
    if (tool == "circle") {
      drawingBloc?.dispatch(CircleOptionEvent(label: ""));
    } else {
      drawingBloc?.dispatch(PolygonOptionEvent(label: ""));
    }
  }

  void onSelectedCommand(String cmd) {
    if (cmd is String) {
      ///search in the list of strings the Enum value of command
      hook.command = Command.values.firstWhere((c) => c.name == cmd);
    }
  }

  void onCreateChannel() {
    var create = CreateHook();
    hook.detection.clear();
    for (var option in detectOptions) {
      if (option.selected) {
        hook.detection.add(option.detection);
      }
    }

    create.hook = hook;
    _streamCtrl.sink.add(create);
  }

  void onCancel() {
    _streamCtrl.sink.add(null);
  }
}
