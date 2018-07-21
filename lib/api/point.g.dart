// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) =>
    new Point((json['x'] as num)?.toDouble(), (json['y'] as num)?.toDouble());

abstract class _$PointSerializerMixin {
  double get x;
  double get y;
  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y};
}
