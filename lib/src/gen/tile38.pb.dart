///
//  Generated code. Do not modify.
//  source: tile38.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:protobuf/protobuf.dart' as $pb;

import 'tile38.pbenum.dart';

export 'tile38.pbenum.dart';

class CreateFence extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CreateFence')
    ..aOS(1, 'group')
    ..e<Detection>(2, 'detection', $pb.PbFieldType.OE, Detection.enter, Detection.valueOf, Detection.values)
    ..e<Command>(3, 'command', $pb.PbFieldType.OE, Command.nearby, Command.valueOf, Command.values)
    ..aOS(4, 'area')
    ..hasRequiredFields = false
  ;

  CreateFence._() : super();
  factory CreateFence() => create();
  factory CreateFence.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateFence.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CreateFence clone() => CreateFence()..mergeFromMessage(this);
  CreateFence copyWith(void Function(CreateFence) updates) => super.copyWith((message) => updates(message as CreateFence));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CreateFence create() => CreateFence._();
  CreateFence createEmptyInstance() => create();
  static $pb.PbList<CreateFence> createRepeated() => $pb.PbList<CreateFence>();
  static CreateFence getDefault() => _defaultInstance ??= create()..freeze();
  static CreateFence _defaultInstance;

  $core.String get group => $_getS(0, '');
  set group($core.String v) { $_setString(0, v); }
  $core.bool hasGroup() => $_has(0);
  void clearGroup() => clearField(1);

  Detection get detection => $_getN(1);
  set detection(Detection v) { setField(2, v); }
  $core.bool hasDetection() => $_has(1);
  void clearDetection() => clearField(2);

  Command get command => $_getN(2);
  set command(Command v) { setField(3, v); }
  $core.bool hasCommand() => $_has(2);
  void clearCommand() => clearField(3);

  $core.String get area => $_getS(3, '');
  set area($core.String v) { $_setString(3, v); }
  $core.bool hasArea() => $_has(3);
  void clearArea() => clearField(4);
}

class GeofenceEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GeofenceEvent')
    ..e<Detection>(1, 'detection', $pb.PbFieldType.OE, Detection.enter, Detection.valueOf, Detection.values)
    ..aOS(2, 'object')
    ..aOS(3, 'group')
    ..aOS(4, 'time')
    ..aOS(5, 'area')
    ..hasRequiredFields = false
  ;

  GeofenceEvent._() : super();
  factory GeofenceEvent() => create();
  factory GeofenceEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GeofenceEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GeofenceEvent clone() => GeofenceEvent()..mergeFromMessage(this);
  GeofenceEvent copyWith(void Function(GeofenceEvent) updates) => super.copyWith((message) => updates(message as GeofenceEvent));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GeofenceEvent create() => GeofenceEvent._();
  GeofenceEvent createEmptyInstance() => create();
  static $pb.PbList<GeofenceEvent> createRepeated() => $pb.PbList<GeofenceEvent>();
  static GeofenceEvent getDefault() => _defaultInstance ??= create()..freeze();
  static GeofenceEvent _defaultInstance;

  Detection get detection => $_getN(0);
  set detection(Detection v) { setField(1, v); }
  $core.bool hasDetection() => $_has(0);
  void clearDetection() => clearField(1);

  $core.String get object => $_getS(1, '');
  set object($core.String v) { $_setString(1, v); }
  $core.bool hasObject() => $_has(1);
  void clearObject() => clearField(2);

  $core.String get group => $_getS(2, '');
  set group($core.String v) { $_setString(2, v); }
  $core.bool hasGroup() => $_has(2);
  void clearGroup() => clearField(3);

  $core.String get time => $_getS(3, '');
  set time($core.String v) { $_setString(3, v); }
  $core.bool hasTime() => $_has(3);
  void clearTime() => clearField(4);

  $core.String get area => $_getS(4, '');
  set area($core.String v) { $_setString(4, v); }
  $core.bool hasArea() => $_has(4);
  void clearArea() => clearField(5);
}

enum Packet_Data {
  createFence, 
  notSet
}

class Packet extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, Packet_Data> _Packet_DataByTag = {
    1 : Packet_Data.createFence,
    0 : Packet_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Packet')
    ..oo(0, [1])
    ..a<CreateFence>(1, 'createFence', $pb.PbFieldType.OM, CreateFence.getDefault, CreateFence.create)
    ..hasRequiredFields = false
  ;

  Packet._() : super();
  factory Packet() => create();
  factory Packet.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Packet.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Packet clone() => Packet()..mergeFromMessage(this);
  Packet copyWith(void Function(Packet) updates) => super.copyWith((message) => updates(message as Packet));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Packet create() => Packet._();
  Packet createEmptyInstance() => create();
  static $pb.PbList<Packet> createRepeated() => $pb.PbList<Packet>();
  static Packet getDefault() => _defaultInstance ??= create()..freeze();
  static Packet _defaultInstance;

  Packet_Data whichData() => _Packet_DataByTag[$_whichOneof(0)];
  void clearData() => clearField($_whichOneof(0));

  CreateFence get createFence => $_getN(0);
  set createFence(CreateFence v) { setField(1, v); }
  $core.bool hasCreateFence() => $_has(0);
  void clearCreateFence() => clearField(1);
}

