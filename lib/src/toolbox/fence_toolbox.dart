import 'package:angular_bloc/angular_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';

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
class FenceToolboxComponent with Dragging {
  final drawToolboxBloc = ToolboxBloc(); //toolbox appearance
  final shapesBloc = AreaBloc(); //final shapes processor

  @Input()
  set map(OpenStreetMap value) {
    sketchBloc?.map = value;
    shapesBloc.state.listen((AreaState s) {
      if (s is AreaCreatedState) {
        fenceObject = s.shape.description;
        s.shape.dispose();
        sketchBloc.dispatch(EndOptionEvent());
      }
    });
  }

  @Input()
  ToolboxState state;

  SketchBloc sketchBloc; //dawing shapes processor

  String fenceObject = "";

  final List<String> groups;
  FenceToolboxComponent(DataStore store)
      : groups = store.fleet.map((x) => x.name).toList() {
    sketchBloc = SketchBloc(shapesBloc);

    initDragging(container: "#map-editor");
    makeDraggable("#draw", drawToolboxBloc);
  }

  final drawOptions = <OptionsEvent>[
    CircleOptionEvent(label: "Circle"),
    PolygonOptionEvent(label: "Polygon")
  ];

  @ViewChild(ToolboxComponent)
  ToolboxComponent sketchToolbox;

  @Input()
  Bloc optionBloc; //notify the bloc with selection events

  final commands = <String>["nearby", "within", "intersects"];
  final detection = <String>[
    "all",
    "enter",
    "exit",
    "inside",
    "outside",
    "cross"
  ];

  void onMapSelector(bool visible) {
    sketchToolbox.enabled = visible;
    drawToolboxBloc
        .dispatch(visible ? ShowToolEvent([460, 0]) : HideToolEvent());
  }
}
