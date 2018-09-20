import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/MapUtil.dart';

part './dining_hall_hours.g.dart';

@JsonSerializable()
class DiningHallHours extends Object with _$DiningHallHoursSerializerMixin {
  DiningHallHours({
    this.extra,
    this.closeTimesRaw,
    this.openTimesRaw,
    this.closed = false,
    this.begin = -1.0,
    this.end = -1.0,
    this.limitedMenuBegin = -1.0,
    this.grillClosesAt = -1.0,
    this.mealOrdinal = -1,
    })
      : this.closeTimes = MapUtil.mapValues(closeTimesRaw, (v) => timeFromHour(v)),
        this.openTimes = MapUtil.mapValues(openTimesRaw, (v) => timeFromHour(v));

  final bool closed;
  final double begin;
  final double end;
  final double limitedMenuBegin;
  final double grillClosesAt;
  final String extra;
  @JsonKey(name: 'meal')
  final int mealOrdinal;
  @JsonKey(name: 'closeTimes')
  final Map<String, num> closeTimesRaw;
  @JsonKey(name: 'openTimes')
  final Map<String, num> openTimesRaw;
  @JsonKey(ignore: true)
  final Map<String, TimeOfDay> closeTimes;
  @JsonKey(ignore: true)
  final Map<String, TimeOfDay> openTimes;

  bool get isLimitedMenu => this.begin == this.limitedMenuBegin;
  bool get isGrillClosed => this.begin == this.grillClosesAt;
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
      // minutes -= 1;
    }

    int hour = time.floor();

    if (hour != 24) {
      // hour -= 1;
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

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DiningHallHours
        && (
          this.mealOrdinal == other.mealOrdinal
            && this.closed == other.closed
            && this.begin == other.begin
            && this.end == other.end
            && this.limitedMenuBegin == other.limitedMenuBegin
            && this.grillClosesAt == other.grillClosesAt
            && this.extra == other.extra
        );
  }

  @override
  int get hashCode {
    int prime = 31;
    int result = 17;

    result = prime * result + (closed ? 1 : 0);
    result = prime * result + beginTime.hashCode;
    result = prime * result + endTime.hashCode;
    result = prime * result + limitedMenuTime.hashCode;
    result = prime * result + grillCloseTime.hashCode;
    result = prime * result + mealOrdinal.hashCode;
    result = prime * result + (extra ?? '').hashCode;

    return result;
  }
}