import 'package:meta/meta.dart';
import 'package:webtile38/src/sketch_maker/draw.dart';

@immutable
abstract class DrawingState {
}

class InactiveDrawingState extends DrawingState {}

class ActiveDrawingState extends DrawingState {
  final Draw drawer;
  ActiveDrawingState(this.drawer);
}
