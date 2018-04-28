import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String toTimeString(DateTime from) {
    return new DateFormat.jm().format(from);
  }

  static String getWeekday(DateTime from) {
    return new DateFormat("EEEE").format(from);
  }

  static String formatTimeOfDay(TimeOfDay from) {
    return '${from.hour}:${from.minute}${from.period == DayPeriod.am ? 'am' : 'pm'}';
  }

  static double timeToDouble(TimeOfDay toConvert) {
    return toConvert.hour + (toConvert.minute / 60);
  }

  /// Return a positive integer if a is later than b
  /// Return zero if a is the same time as b
  /// Return a negative integer if a is earlier than b
  static double compareTime(TimeOfDay a, TimeOfDay b) {
    return timeToDouble(a) - timeToDouble(b);
  }
}