import 'dart:async';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';

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
  final hook = Hook();
  final drawToolboxBloc = ToolboxBloc(); //toolbox appearance
  final areasBloc = AreaBloc(); //final shapes processor

  final allCommands = Command.values.map((c) => c.name).toList();
  final allDetections = Detection.values.map((c) => c.name).toList();

  StreamSubscription _subscription;

  String areaText;

  @Output()
  Stream<CreateHook> get created => _streamCtrl.stream;

  @Input()
  ToolboxState state;

  SketchBloc drawingBloc; //dawing shapes processor

  final List<String> groups;

  Area _makeArea(String text) {
    var area = Area();
    if (!text.startsWith("POINT")) {
      area.json = GeoJson()..value = text;
    } else {
      final tokens = text.split(" ");
      area.point = Point()..center = LatLng();
      area.point.center.lat = double.parse(tokens[1]);
      area.point.center.lng = double.parse(tokens[2]);
      area.point.radius = double.parse(tokens[3]);
    }
    return area;
  }

  @Input()
  set map(OpenStreetMap value) {
    drawingBloc?.map = value;
    _subscription = areasBloc.state.listen((AreaState s) {
      if (s is AreaCreatedState) {
        areaText = s.shape.description;
        hook.area = _makeArea(s.shape.description);
        s.shape.dispose();
        drawingBloc.dispatch(EndOptionEvent());
      } else if (s is AreaDrawInProgress) {
        areaText = s.message;
      }
    });
  }

  final drawOptions = <OptionsEvent>[
    CircleOptionEvent(label: "Circle"),
    PolygonOptionEvent(label: "Polygon")
  ];

  @ViewChild(ToolboxComponent)
  ToolboxComponent sketchToolbox;

  FenceToolboxComponent(DataStore store)
      : groups = store.fleet.map((x) => x.name).toList() {
    drawingBloc = SketchBloc(areasBloc);

    initDragging(container: "#map-editor");
    makeDraggable("#draw", drawToolboxBloc);
  }

  @override
  void ngOnDestroy() {
    drawingBloc.dispose();
    areasBloc.dispose();
    _subscription?.cancel();
  }

  void onMapSelector(bool visible) {
    sketchToolbox.enabled = visible;
    drawToolboxBloc
        .dispatch(visible ? ShowToolEvent([320, 0]) : HideToolEvent());
  }

  void onSelectedCommand(String cmd) {
    if (cmd is String) {
      //search in the list of strings the Enum value of command
      hook.command = Command.values.firstWhere((c) => c.name == cmd);
    }
  }

  void onSelectedDetection(String detect) {
    //search in the list of available strings
    if (detect is String) {
      hook.detection = Detection.values.firstWhere((c) => c.name == detect);
    }
  }

  void onCreateChannel() {
    var create = CreateHook();
    create.hook = hook;
    _streamCtrl.sink.add(create);
  }

  void onCancel() {
    _streamCtrl.sink.add(null);
  }
}
