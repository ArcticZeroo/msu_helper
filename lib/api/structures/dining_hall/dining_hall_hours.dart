import 'package:json_annotation/json_annotation.dart';

part 'package:msu_helper/api/structures/dining_hall/dining_hall_hours.g.dart';

@JsonSerializable()
class DiningHallHours extends Object with _$DiningHallHoursSerializerMixin {
  DiningHallHours({
    this.closed = false,
    this.begin,
    this.end,
    this.limitedMenuBegin,
    this.grillClosesAt,
    this.meal,
    this.extra
  });

  final bool closed;
  int begin;
  int end;
  int limitedMenuBegin;
  int grillClosesAt;
  int meal;
  String extra;

  factory DiningHallHours.fromJson(Map<String, dynamic> json) => _$DiningHallHoursFromJson(json);
}