import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/util/NumberUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';

class DateUtil {
  static const List<int> WEEKDAYS = [
    DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday,
    DateTime.thursday, DateTime.friday, DateTime.saturday,
  ];

  static const List<String> WEEKDAY_NAMES = [
    'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'
  ];

  static const List<String> WEEKDAY_ABBREVIATIONS = [
    'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'
  ];

  static const Duration EASTERN_TIMEZONE_OFFSET = const Duration(hours: -5);

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

  static int getWeekdayValue(String weekday) {
    return WEEKDAYS[WEEKDAY_NAMES.indexOf(weekday.toLowerCase())];
  }

  static String toTimeString(DateTime from) {
    return new DateFormat.jm().format(from);
  }

  static String getWeekday(DateTime from) {
    return new DateFormat("EEEE").format(from);
  }

  static String formatTimeOfDay(TimeOfDay from, [int add = 0]) {
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

  static String formatDateFully(DateTime from) {
    return new DateFormat("EEEE, MMMM d'${TextUtil.getOrdinalSuffix(from.day)}', y").format(from);
  }

  static DateTime zeroOutDay(DateTime from) {
    return from.subtract(new Duration(
      hours: from.hour,
      minutes: from.minute,
      seconds: from.second,
      milliseconds: from.millisecond,
      microseconds: from.microsecond
    ));
  }

  static Map<String, List<DateTime>> groupByWeekday(List<DateTime> dates) {
    Map<String, List<DateTime>> datesByWeekday = {};

    for (DateTime showing in dates) {
      String weekday = DateUtil.getWeekday(showing);

      if (!datesByWeekday.containsKey(weekday)) {
        datesByWeekday[weekday] = [];
      }

      datesByWeekday[weekday].add(showing);
    }

    List<String> sortedWeekdays = datesByWeekday.keys.toList();
    sortedWeekdays.sort((a, b) => DateUtil.getWeekdayValue(a) - DateUtil.getWeekdayValue(b));

    for (String weekday in sortedWeekdays) {
      List<DateTime> showingsForWeekday = datesByWeekday[weekday];
      showingsForWeekday.sort((a, b) => a.compareTo(b));
    }

    return datesByWeekday;
  }
}