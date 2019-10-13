import 'package:dartleaf/dartleaf.dart' as m;
import 'draw.dart';

class DrawRectangle implements Draw {

  String _label;
  m.Tooltip _labelTooltip;

  set label(String text) {
    _label = text;
    _labelTooltip?.setTooltipContent(_label);
  }

  // DrawRectangle(this._map, this._bloc, [this._label]);

  @override
  set active(bool draw) {}
}
