import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/util/DateUtil.dart';

class MenuDate {
  DateTime _time;

  MenuDate([this._time]) {
    if (_time == null) {
      _time = DateTime.now();
    }
  }

  DateTime get time => _time;
  String get weekday => DateUtil.getWeekday(time);

  void forward() {
    _time = _time.add(Duration(days: 1));
  }

  void back() {
    _time = _time.subtract(Duration(days: 1));
  }

  void now() {
    _time = DateTime.now();
  }

  static DiningHallHours getFirstRelevant(List<DiningHallHours> hoursOnDay, TimeOfDay timeOfDay) {
    return hoursOnDay.firstWhere((hours) {
      if (hours.closed) {
        return false;
      }

      // If the end time has already passed, get rid of it
      if (timeOfDay.hour > hours.endTime.hour) {
        return false;
      }

      if (timeOfDay.hour == hours.endTime.hour
          && timeOfDay.minute >= hours.endTime.minute) {
        return false;
      }

      return true;
    }, orElse: () => null);
  }

  static DiningHallHours getMostRelevant(Map<String, List<DiningHallHours>> hours, DateTime start) {
    for (int i = 0; i < 7; ++i) {
      List<DiningHallHours> hoursOnDay = hours[DateUtil.getWeekday(start).toLowerCase()];

      DiningHallHours found;
      if (i == 0) {
        TimeOfDay timeOfDay = TimeOfDay.fromDateTime(start);

        found = hoursOnDay.firstWhere((hours) {
          if (hours.closed) {
            return false;
          }

          // If the end time has already passed, get rid of it
          if (timeOfDay.hour < hours.endTime.hour) {
            return false;
          }

          if (timeOfDay.hour == hours.endTime.hour
              && timeOfDay.minute < hours.endTime.minute) {
            return false;
          }

          return true;
        }, orElse: () => null);
      } else {
        found = hoursOnDay.firstWhere((hours) => !hours.closed, orElse: () => null);
      }

      if (found != null) {
        return found;
      }

      start.add(Duration(days: 1));
    }

    return null;
  }

  List<DiningHallHours> getDayHours(DiningHall diningHall) {
    String day = DateUtil.getWeekday(_time).toLowerCase();

    return diningHall.hours[day];
  }

  DiningHallHours getMealHours(DiningHall diningHall, Meal meal) {
    return getDayHours(diningHall)[meal.ordinal];
  }

  String getFormatted() {
    return new DateFormat("yyyy-MM-dd").format(_time);
  }

  factory MenuDate.fromFormatted(String formatted) {
    return new MenuDate(DateTime.parse(formatted));
  }

  @override
  String toString() {
    return "MenuDate[${getFormatted()}]";
  }
}