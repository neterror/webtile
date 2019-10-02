import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/toolbox/dragging.dart';
import 'package:webtile38/src/toolbox/fence_cmd_model.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/toolbox/fence_toolbox.dart';
import 'package:webtile38/src/sketch_maker/draw_directive.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'package:webtile38/src/cli_console/bloc/bloc.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';

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
  final _subscriptions = <StreamSubscription> [];
  final fenceToolboxBloc = ToolboxBloc(); //toolbox appearance
  final _channels = <Tile38cliBloc>[];

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

  void onChannelCreated(FenceCmdModel fence) {
    var detection = "";
    if (fence.detection != "all") {
      detection = " DETECT ${fence.detection}";
    }
    var cmd =
        "SETCHAN ${fence.channel} ${fence.command} ${fence.group} FENCE${detection} ${fence.area}";

    var channel = Tile38cliBloc(protocol: _protocol);
    var sub = channel.state.listen(print);

    _channels.add(channel);
    _subscriptions.add(sub);
    channel.dispatch(Tile38CmdEvent(cmd));
  }
}

/**
 * Toolboxes
 *  search - map to commands to tile32
 *  draw 
 *  edit 
 *  
 */
