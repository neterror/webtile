import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';

@Component(
    selector: 'geofence-list',
    templateUrl: 'geofence_list_component.html',
    styleUrls: ['geofence_list_component.css'],
    directives: [MaterialListComponent, MaterialListItemComponent, MaterialButtonComponent])
class GeofenceListComponent implements OnInit, OnDestroy {
  Tile38Proto _protocol;
  GeofenceListComponent(this._protocol);
  StreamSubscription _sub;

  @override
  void ngOnInit() {
    _sub = _protocol.received.listen(_onReceived);
  }

  @override
  void ngOnDestroy() {
    _sub.cancel();
  }

  void _onReceived(dynamic data) {
    if (data is! Packet) return;
    Packet packet = data;
    if (packet.whichData() == Packet_Data.hooks) {
      for (Hook h in packet.hooks.items) {
        print("hook: $h");
      }
    }
  }

  void getHookList() {
    final request = GetHooks();
    request.pattern = "*";
    final packet = Packet()..getHooks = request;
    _protocol.send(packet);
  }
}
