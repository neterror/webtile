import 'dart:async';

import 'package:angular_bloc/angular_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'fence_cmd_model.dart';

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
  final fenceCmd = FenceCmdModel();
  final drawToolboxBloc = ToolboxBloc(); //toolbox appearance
  final areasBloc = AreaBloc(); //final shapes processor

  static const allCommands = FenceCmdModel.allowedCmd;  //to make them visible in the html
  static const allDetections = FenceCmdModel.allowedDetection;

  StreamSubscription _subscription;

  @Input()
  ToolboxState state;
  SketchBloc drawingBloc; //dawing shapes processor
  String fenceObject = "";

  final List<String> groups;

  @Input()
  set map(OpenStreetMap value) {
    drawingBloc?.map = value;
    _subscription = areasBloc.state.listen((AreaState s) {
      if (s is AreaCreatedState) {
        fenceObject = s.shape.description;
        s.shape.dispose();
        drawingBloc.dispatch(EndOptionEvent());
      }
    });
  }

  final drawOptions = <OptionsEvent>[
    CircleOptionEvent(label: "Circle"),
    PolygonOptionEvent(label: "Polygon")
  ];

  @ViewChild(ToolboxComponent)
  ToolboxComponent sketchToolbox;

  @Input()
  Bloc optionBloc; //notify the bloc with selection events


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
        .dispatch(visible ? ShowToolEvent([460, 0]) : HideToolEvent());
  }
  
  void onCreateChannel() {
    print("created command: $fenceCmd");
  }
}
