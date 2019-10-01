import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/fence_toolbox.dart';
import 'package:webtile38/src/sketch_maker/draw_directive.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';


@Component(selector: 'map-editor', templateUrl: 'map_editor.html', styleUrls: [
  'map_editor.css'
], pipes: [
  BlocPipe
], directives: [
  OpenStreetMap,
  ToolboxComponent,
  MaterialInputComponent,
  MaterialToggleComponent,
  DrawDirective,
  FenceToolboxComponent
])
class MapEditorComponent with Dragging implements AfterViewInit  {

  @ViewChild(OpenStreetMap)
  OpenStreetMap map;

  final drawToolboxBloc = ToolboxBloc(); //toolbox appearance
  final areaBloc = AreaBloc(); //final shapes processor
  SketchBloc sketchBloc; //dawing shapes processor

  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance

  MapEditorComponent() {
    sketchBloc = SketchBloc(areaBloc);
  }

  final drawOptions = <OptionsEvent>[
    PolygonOptionEvent(label: "Polygon"),
    RectangleOptionEvent(label: "Rectangle"),
    CircleOptionEvent(label: "Circle")
  ];


  @override
  void ngAfterViewInit() {
    initDragging(container: "#map-editor");
    makeDraggable("#draw", drawToolboxBloc);
    makeDraggable("#fence", fenceToolboxBloc);

    sketchBloc.map = map;
  }

  void onShowDraw(bool visible) {
    drawToolboxBloc
        .dispatch(visible ? ShowToolEvent([100, 100]) : HideToolEvent());
  }

  void onFenceEditor(bool visible) {
    fenceToolboxBloc
        .dispatch(visible ? ShowToolEvent([200, 100]) : HideToolEvent());
  }
}

/**
 * Toolboxes
 *  search - map to commands to tile32
 *  draw 
 *  edit 
 *  
 */
