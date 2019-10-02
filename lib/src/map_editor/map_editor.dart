import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
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
  DrawDirective,
  FenceToolboxComponent
])
class MapEditorComponent with Dragging implements AfterViewInit, OnDestroy {
  @ViewChild(OpenStreetMap)
  OpenStreetMap map;

  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance

  @override
  void ngAfterViewInit() {
    initDragging(container: "#map-editor");
    makeDraggable("#fence", fenceToolboxBloc);
    fenceToolboxBloc.dispatch(ShowToolEvent([100, 400]));
  }

  @override
  void ngOnDestroy() {
    fenceToolboxBloc.dispose();
  }
}

/**
 * Toolboxes
 *  search - map to commands to tile32
 *  draw 
 *  edit 
 *  
 */
