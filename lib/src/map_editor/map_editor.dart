import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/toolbox/fence_cmd_model.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/fence_toolbox.dart';
import 'package:webtile38/src/sketch_maker/draw_directive.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';

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
  Tile38Proto _protocol;
  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance

  MapEditorComponent(this._protocol);

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

  final _cmd = <String, Command>{
    "nearby": Command.nearby,
    "intersects": Command.intersects,
    "within": Command.within
  };

  final _detection = <String, Detection>{
    "enter": Detection.enter,
    "leave": Detection.leave,
    "inside": Detection.inside,
    "outside": Detection.outside,
    "cross": Detection.cross,
    "all": Detection.all
  };

  void onChannelCreated(FenceCmdModel fence) {
    final packet = Packet();
    packet.createFence = CreateFence();
    packet.createFence.command = _cmd[fence.command];
    packet.createFence.area = fence.area;
    packet.createFence.group = fence.group;
    packet.createFence.detection = _detection[fence.detection];

    _protocol.send(packet);
  }
}

/**
 * Toolboxes
 *  search - map to commands to tile32
 *  draw 
 *  edit 
 *  
 */
