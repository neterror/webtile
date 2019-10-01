import 'package:bloc/bloc.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';

@Component(templateUrl: 'toolbox.html', selector: 'toolbox', styleUrls: [
  'toolbox.css'
], directives: [
  coreDirectives,
  NgModel,
  MaterialToggleComponent,
  MaterialRadioComponent,
  MaterialRadioGroupComponent,
  MaterialInputComponent,
  materialInputDirectives,
  NgClass,
  NgStyle
])
class ToolboxComponent implements OnInit {
  @Input()
  ToolboxState state;

  bool _enabled = false;
  bool get enabled => _enabled;

  @Input()
  set enabled (bool value) {
    _enabled = value;
    onEnabled(value);
  }

  @Input()
  bool canDisable = true;

  OptionsEvent selected;

  @override
  ngOnInit() {
    selected = options[0];
    onEnabled(enabled);
  }

  /// output notifications dispatcher
  @Input()
  Bloc optionBloc;

  /// Events that can be selected and dispatched
  @Input()
  List<OptionsEvent> options;

  @Input()
  String toolboxLabel;

  @Input()
  String dataLabel;

  String dataText = "";

  void onToolChange(OptionsEvent tool) {
    if (enabled) {
      tool.text = dataText;
      optionBloc.dispatch(tool);
    }
  }

  void onEnabled(bool status) {
    _enabled = status;
    if (enabled) {
      selected?.text = dataText;
      optionBloc.dispatch(selected);
    } else {
       optionBloc.dispatch(EndOptionEvent());
    }
  }
}
