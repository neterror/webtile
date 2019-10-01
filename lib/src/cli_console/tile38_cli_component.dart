import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/cli_console/bloc/bloc.dart';

@Component(
    selector: 'tile38-cli',
    templateUrl: 'tile38_cli_component.html',
    styleUrls: [
      'tile38_cli_component.css'
    ],
    providers: [
      materialProviders
    ],
    directives: [
      coreDirectives,
      NgModel,
      MaterialListComponent,
      MaterialInputComponent,
      materialInputDirectives,
      MaterialButtonComponent,
      AutoFocusDirective
    ])
class CliComponent {
  String command;
  @Input()
  Tile38cliBloc bloc;

  @Input()
  Tile38cliState state;

  bool get isResponded => state is ResponseReceivedState;

  String get response => (state as ResponseReceivedState).toString();

  void onSend() {
    bloc.dispatch(Tile38CmdEvent(command));
  }
}
