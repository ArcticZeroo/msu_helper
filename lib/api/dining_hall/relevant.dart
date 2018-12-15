import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';

String formatOpenNext(MenuDate menuDate, DiningHallHours mealHours) {
  return 'It opens for ${mealHours.meal.name} '
      'on ${DateUtil.getWeekday(menuDate.time)} '
      'at ${DateUtil.formatTimeOfDay(mealHours.beginTime)}';
}

// TODO: Wtf is this method?
List<String> getSuperRelevantLines(DiningHall diningHall) {
  MenuDate menuDate = MenuDate.now();
  List<DiningHallHours> hoursToday = menuDate.getDayHours(diningHall);
  List<String> text = [];

  // If it's closed today
  if (DiningHallHours.isFullyClosed(hoursToday)) {
    text.add('It\'s closed today.');

    for (int i = 1; i < 7; i++) {
      menuDate.forward();

      List<DiningHallHours> nextHours = menuDate.getDayHours(diningHall);
      if (!DiningHallHours.isFullyClosed(nextHours)) {
        DiningHallHours relevant = MenuDate.getFirstRelevant(
            nextHours,
            new TimeOfDay(hour: 0, minute: 0)
        );

        if (relevant != null) {
          text.add(formatOpenNext(menuDate, relevant));
        }

        return text;
      }
    }

    text.add('It doesn\'t look like it will be open again this week.');

    return text;
  }

  TimeOfDay timeNow = TimeOfDay.now();
  DiningHallHours relevant = MenuDate.getFirstRelevant(hoursToday, timeNow);

  if (relevant != null) {
    if (relevant.isNow()) {
      text.add(
          'It\'s currently serving ${relevant.meal.name} '
              'until ${DateUtil.formatTimeOfDay(relevant.endTime)}'
      );
    } else {
      text.add(
          'It will serve ${relevant.meal.name} '
              'at ${DateUtil.formatTimeOfDay(relevant.beginTime)}'
      );
    }
    return text;
  }

  for (int i = 1; i < 7; i++) {
    menuDate.forward();

    List<DiningHallHours> nextHours = menuDate.getDayHours(diningHall);
    if (!DiningHallHours.isFullyClosed(nextHours)) {
      DiningHallHours relevant = MenuDate.getFirstRelevant(
          nextHours,
          new TimeOfDay(hour: 0, minute: 0)
      );

      if (relevant != null) {
        text.add(
            'It will serve ${relevant.meal.name} on '
                '${DateUtil.getWeekday(menuDate.time)} at ${DateUtil.formatTimeOfDay(relevant.beginTime)}'
        );
      } else {
        text.add('The next opening can\'t be found.');
      }

      return text;
    }
  }

  text.add('The next opening can\'t be found.');
  return text;
}