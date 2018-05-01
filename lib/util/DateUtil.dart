import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/util/ListUtil.dart';
import 'package:msu_helper/util/NumberUtil.dart';

class DateUtil {
  static const WEEKDAYS = [
    DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday,
    DateTime.thursday, DateTime.friday, DateTime.saturday,
  ];

  static const WEEKDAY_NAMES = [
    'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'
  ];

  static const WEEKDAY_ABBREVIATIONS = [
    'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'
  ];

  static String getAbbreviation(dynamic from) {
    int index;

    // Assume it is a weekday value...
    if (from is int) {
      index = WEEKDAYS.indexOf(from);
      // Assume it's a weekday name
    } else if (from is String) {
      index = WEEKDAY_NAMES.indexOf(from.toLowerCase());
    } else {
      throw new TypeError();
    }

    return WEEKDAY_ABBREVIATIONS[index];
  }

  static String toTimeString(DateTime from) {
    return new DateFormat.jm().format(from);
  }

  static String getWeekday(DateTime from) {
    return new DateFormat("EEEE").format(from);
  }

  static String formatTimeOfDay(TimeOfDay from, [int add = 1]) {
    if (from.hour == 24) {
      return 'Midnight';
    }

    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10)
        return '0$value';
      return value.toString();
    }

    int minute = NumberUtil.round(from.minute.toDouble(), 5);

    final String minuteLabel = _addLeadingZeroIfNeeded(minute);

    return '${(from.hour + add) - from.periodOffset}:$minuteLabel ${from.period == DayPeriod.am ? 'am' : 'pm'}';
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

  static String formatDifference(Duration difference) {
    String differenceString = '${difference.inMinutes % 60}m';

    if (difference.inHours >= 1) {
      differenceString = '${difference.inHours}h $differenceString';
    }

    return differenceString;
  }
}