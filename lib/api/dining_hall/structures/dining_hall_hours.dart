import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/util/DateUtil.dart';

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

  isNow() {
    TimeOfDay now = TimeOfDay.now();

    double startCompare = DateUtil.compareTime(now, beginTime);

    // If the double is negative now is before beginTime
    if (startCompare < 0) {
      return false;
    }
    
    double endCompare = DateUtil.compareTime(now, endTime);

    // If the double is negative, now is before endTime
    // and is therefore happening now
    if (endCompare < 0) {
      return true;
    }

    return false;
  }

  static TimeOfDay timeFromHour(double time) {
    double minuteDecimal = time - time.truncate();
    int minutes = (minuteDecimal * 60).floor();

    if (minutes > 0) {
      minutes -= 1;
    }

    int hour = time.floor();

    if (hour != 24) {
      hour -= 1;
    }

    return new TimeOfDay(
        hour: hour,
        minute: minutes
    );
  }

  static bool isFullyClosed(List<DiningHallHours> hours) {
    return hours.where((mealHours) => !mealHours.closed).toList().length == 0;
  }

  @override
  String toString() {
    return 'DiningHallHours'
        '(${meal.name})' +
        (closed ? '[Closed]' : '[${DateUtil.formatTimeOfDay(beginTime)}-${DateUtil.formatTimeOfDay(endTime)}]');
  }
}