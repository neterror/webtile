import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:webtile38/src/cli_console/tile38_cli_component.dart';
import 'package:webtile38/src/cli_console/bloc/bloc.dart';
import 'package:webtile38/src/map_editor/map_editor.dart';
import 'package:webtile38/src/fleet_editor/fleet_editor_component.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'package:webtile38/src/providers/datastore.dart';

@Component(
    selector: 'my-app',
    styleUrls: [
      'app_component.css',
      'package:angular_components/app_layout/layout.scss.css',
    ],
    templateUrl: 'app_component.html',
    providers: [
      FactoryProvider(Tile38Proto, protocolFactory),
      ClassProvider(DataStore)
    ],
    directives: [
      coreDirectives,
      CliComponent,
      MapEditorComponent,
      DeferredContentDirective,
      MaterialListItemComponent,
      MaterialListComponent,
      MaterialToggleComponent,
      FixedMaterialTabStripComponent,
      FleetEditorComponent,
    ],
    pipes: [BlocPipe])
class AppComponent implements OnInit, OnDestroy {
  int activeTab = 0;
  Tile38cliBloc cliBloc;
  Tile38Proto _protocol;

  final tabLabels = <String>["Map Editor", "Fleet", "CLI"];

  AppComponent(this._protocol);

  void onTabChange(int index) => activeTab = index;

  @override
  void ngOnInit() {
    cliBloc = Tile38cliBloc(protocol: _protocol);
  }

  @override
  void ngOnDestroy() {
    cliBloc.dispose();
  }
}
