import 'package:dartleaf/dartleaf.dart' as m;
import 'package:webtile38/src/toolbox/bloc/bloc.dart';
import 'draw.dart';

class DrawRectangle implements Draw {
  final m.LeafletMap _map;
  String _label;
  m.Tooltip _labelTooltip;
  AreaBloc _bloc;

  set label(String text) {
    _label = text;
    _labelTooltip?.setTooltipContent(_label);
  }

  DrawRectangle(this._map, this._bloc, [this._label]);

  @override
  set active(bool draw) {
  }


}
