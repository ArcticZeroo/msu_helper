import 'package:json_annotation/json_annotation.dart';

part './point.g.dart';

@JsonSerializable()
class Point extends Object with _$PointSerializerMixin {
  double x;
  double y;
  
  Point([this.x = 0.0, this.y = 0.0]);

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  bool get isNull => x == 0 && y == 0;
}