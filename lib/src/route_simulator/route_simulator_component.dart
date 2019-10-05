import 'dart:html';
import 'package:dartleaf/dartleaf.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/map_component/open_street_map.dart';
import 'vehicle_path.dart';
import 'bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';

@Component(
    selector: 'route-simulator',
    templateUrl: 'route_simulator_component.html',
    pipes: [
      BlocPipe
    ],
    directives: [
      coreDirectives,
      MaterialSelectItemComponent,
      MaterialListComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      OpenStreetMap,
    ],
    styleUrls: [
      'route_simulator_component.css'
    ])
class RouteSimulatorComponent implements AfterViewInit, OnDestroy {
  @Input()
  PathmakerBloc bloc;

  @Input()
  PathmakerState state;

  final paths = <VehiclePath>[];

  @ViewChild(OpenStreetMap)
  OpenStreetMap osm;

  @override
  void ngAfterViewInit() {
    paths.add(VehiclePath(osm.map, "Route1"));
    paths.add(VehiclePath(osm.map, "Route2"));
    paths.add(VehiclePath(osm.map, "Route66"));
  }

  @override
  void ngOnDestroy() {}

  void onNewRoute() {
    _attachEvents();
    bloc.dispatch(PathmakerActiveEvent());
  }

  bool get activeDraw => state is! PathmakerInactiveState;
  bool get reportingPos => state is PathmakerPosState;

  void _attachEvents() {
    osm.map.on(E.click, _mouseClick);
    osm.map.on(E.mousemove,
        (e) => bloc.dispatch(PathmakerPosEvent(e.latlng.lat, e.latlng.lng)));
  }

  _mouseClick(LeafletMouseEvent e) {
    if ((e.originalEvent as MouseEvent).button == 0) {
      var marker = Marker(e.latlng);
      marker.addTo(osm.map);
    } else {}
  }
}
