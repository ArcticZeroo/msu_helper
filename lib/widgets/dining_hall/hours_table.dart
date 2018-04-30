import 'dart:math';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';

class HoursTable extends StatelessWidget {
  final DiningHall diningHall;

  const HoursTable(this.diningHall);
  
  @override
  Widget build(BuildContext context) {
    Map<List<String>, List<DiningHallHours>> grouped = getGroupedHours();

    List<List<String>> groupingsList = grouped.keys.toList();

    groupingsList.sort((a, b) {
      a.sort(sortGroupings);
      b.sort(sortGroupings);

      return sortGroupings(a.first, b.first);
    });

    List<String> headerRow = <String>[''];
    List<List<Widget>> dataRows = <List<Widget>>[];
    
    for (Meal meal in Meal.asList()) {
      dataRows.add([new Text(
          meal.name,
          style: new TextStyle(fontWeight: FontWeight.bold)
      )]);
    }

    for (List<String> grouping in groupingsList) {
      List<DiningHallHours> hours = grouped[grouping];

      // Set the header for this grouping
      if (grouping.length == 1) {
        headerRow.add(TextUtil.capitalize(DateUtil.getAbbreviation(grouping.first)));
      } else {
        bool allAdjacent = true;
        for (int i = 0; i < grouping.length - 1; i++) {
          print('Checking if ${grouping[i]} and ${grouping[i + 1]} are adjacent');
          if (!isDayAdjacent(
              DateUtil.WEEKDAY_NAMES.indexOf(grouping[i]),
              DateUtil.WEEKDAY_NAMES.indexOf(grouping[i + 1]))
          ) {
            print('nope');
            allAdjacent = false;
            break;
          }
        }

        List<String> copy = List.from(grouping);
        copy.sort(sortGroupings);

        String header;
        if (allAdjacent) {
          String firstAbbreviation = TextUtil.capitalize(DateUtil.getAbbreviation(copy.first));
          String lastAbbreviation = TextUtil.capitalize(DateUtil.getAbbreviation(copy.last));

          header = '$firstAbbreviation-$lastAbbreviation';
        } else {
          header = copy.map((w) => TextUtil.capitalize(DateUtil.getAbbreviation(w))).join('/');
        }

        headerRow.add(header);
      }

      // Now work on the hours
      List<Widget> columnRows = [];
      hours.sort((a, b) => a.mealOrdinal - b.mealOrdinal);
      for (DiningHallHours mealHours in hours) {
        if (mealHours.closed) {
          columnRows.add(new Center(child: new Text('Closed')));
          continue;
        }

        String main = '${DateUtil.formatTimeOfDay(mealHours.beginTime)} - ${DateUtil.formatTimeOfDay(mealHours.endTime)}';
        List<String> extra = [];

        if (mealHours.limitedMenuBegin != null && mealHours.limitedMenuBegin != -1) {
          if (mealHours.isLimitedMenu) {
            extra.add('limited menu');
          } else {
            extra.add('limited menu from ${DateUtil.formatTimeOfDay(mealHours.limitedMenuTime)} - ${DateUtil.formatTimeOfDay(mealHours.endTime)}');
          }
        }

        if (mealHours.grillClosesAt != null && mealHours.grillClosesAt != -1) {
          extra.add('grill closes at ${DateUtil.formatTimeOfDay(mealHours.grillCloseTime)}');
        }

        if (mealHours.extra != null && mealHours.extra.length != 0) {
          extra.add(mealHours.extra);
        }

        if (extra.length == 0) {
          columnRows.add(new Center(child: new Text(main)));
        } else {
          List<String> columnChildren = [
            main, ''
          ];
          columnChildren.addAll(extra);
          columnRows.add(new Center(
            child: new Column(
              children: columnChildren.map((s) => new Text(s)).toList(),
            ),
          ));
        }
      }

      for (int i = 0; i < columnRows.length; i++) {
        dataRows[i].add(columnRows[i]);
      }
    }

    print(headerRow);
    print(dataRows);

    List<TableRow> rows = [];
    rows.add(new TableRow(children: headerRow.map((s) => new Text(s)).toList()));
    rows.addAll(dataRows.map((row) => new TableRow(children: row)));

    return new Table(
        children: rows
    );
  }

  int sortGroupings(String a, String b) => DateUtil.WEEKDAY_NAMES.indexOf(a) - DateUtil.WEEKDAY_NAMES.indexOf(b);

  bool isDayAdjacent(int dayA, int dayB) {
    if (dayA == dayB) {
      return false;
    }

    int smaller = min(dayA, dayB);
    int larger = max(dayA, dayB);

    return ((smaller + 1) == larger) || ((larger + 1) % DateUtil.WEEKDAYS.length == smaller);
  }
  
  bool sameHours(List<DiningHallHours> a, List<DiningHallHours> b) {
    if (a.length != b.length) {
      return false;
    }
    
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    
    return true;
  }

  Map<List<String>, List<DiningHallHours>> getGroupedHours() {
    Map<List<String>, List<DiningHallHours>> grouped = {};

    for (String day in diningHall.hours.keys) {
      List<DiningHallHours> hours = diningHall.hours[day];

      bool found = false;
      for (List<String> weekdays in grouped.keys) {
        if (sameHours(hours, grouped[weekdays])) {
          weekdays.add(day);
          found = true;
          break;
        }
      }

      if (!found) {
        grouped[[day]] = hours;
      }
    }

    return grouped;
  }
}