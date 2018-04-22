import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/Meal.dart';

part './dining_hall_hours.g.dart';

@JsonSerializable()
class DiningHallHours extends Object with _$DiningHallHoursSerializerMixin {
  DiningHallHours({
    this.closed = false,
    this.begin = 0.0,
    this.end = 0.0,
    this.limitedMenuBegin = 0.0,
    this.grillClosesAt = 0.0,
    this.extra = '',
    this.mealOrdinal = -1
  });

  final bool closed;
  double begin;
  double end;
  double limitedMenuBegin;
  double grillClosesAt;
  String extra;
  @JsonKey(name: 'meal')
  int mealOrdinal;

  bool get isLimitedMenu => this.begin == this.limitedMenuBegin;
  Meal get meal => Meal.fromOrdinal(mealOrdinal);

  TimeOfDay get beginTime => timeFromHour(begin);
  TimeOfDay get endTime => timeFromHour(end);
  TimeOfDay get limitedMenuTime => timeFromHour(limitedMenuBegin);
  TimeOfDay get grillCloseTime => timeFromHour(grillClosesAt);

  factory DiningHallHours.fromJson(Map<String, dynamic> json) => _$DiningHallHoursFromJson(json);

  static TimeOfDay timeFromHour(double time) {
    return new TimeOfDay(
        hour: time.floor() - 1,
        minute: (time - time.truncate() * 60).floor() - 1);
  }
}