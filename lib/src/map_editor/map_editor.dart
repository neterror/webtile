import 'dart:async';

import 'package:angular/angular.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'package:webtile38/src/toolbox/toolbox.dart';
import 'package:webtile38/src/sketch_maker/draw_directive.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';
import 'package:webtile38/src/geofence_list/geofence_list_component.dart';

@Component(selector: 'map-editor', templateUrl: 'map_editor.html', styleUrls: [
  'map_editor.css'
], directives: [
  OpenStreetMap,
  ToolboxComponent,
  DrawDirective,
  GeofenceListComponent
])
class MapEditorComponent  implements AfterViewInit, OnDestroy {
  @ViewChild(OpenStreetMap)
  OpenStreetMap map;
  Tile38Proto _protocol;
  StreamSubscription _sub;

  MapEditorComponent(this._protocol);

  @override
  void ngAfterViewInit() {
    _sub = _protocol.received.listen(_onReceived);
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }


  void _onReceived(dynamic packet) {
    if (packet is! Packet) return;
    switch (packet.whichData()) {
      case Packet_Data.geofenceEvent:
        _geofenceEvent(packet.geofenceEvent);
        break;
      default:
    }
  }

  void _geofenceEvent(GeofenceEvent event) {
    print("received geofence event: ${event}");
  }
}
