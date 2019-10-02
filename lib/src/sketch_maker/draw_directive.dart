import 'package:angular/angular.dart';
import 'package:webtile38/src/toolbox/bloc/bloc.dart';

/// Adds the atribute DrawingState to the map
@Directive(
  selector: '[enableDraw]',
)
class DrawDirective {
  @Input()
  DrawingState state;
}
