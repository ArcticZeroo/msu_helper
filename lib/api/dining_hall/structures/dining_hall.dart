import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';

import '../provider.dart' as diningHallProvider;

part './dining_hall.g.dart';

@JsonSerializable()
class DiningHall extends Object with _$DiningHallSerializerMixin {
  DiningHall({
    this.hallName,
    this.brandName,
    this.fullName,
    this.searchName,
    this.hours
  }) {
    for (List<DiningHallHours> dayHours in hours.values) {
      while (dayHours.length < Meal.count) {
        dayHours.add(new DiningHallHours(
            closed: true,
            mealOrdinal: dayHours.length
        ));
      }
    }
  }

  final String hallName;
  final String brandName;
  final String fullName;
  final String searchName;
  final Map<String, List<DiningHallHours>> hours;

  factory DiningHall.fromJson(Map<String, dynamic> json) => _$DiningHallFromJson(json);

  List<DiningHallHours> getHoursForDay(MenuDate date) {
    return hours[DateUtil.getWeekday(date.time).toLowerCase()];
  }

  DiningHallHours getHoursForMeal(MenuDate date, Meal meal) {
    return getHoursForDay(date)[meal.ordinal];
  }

  Map<DiningHallVenue, List<FoodItem>> findUniqueItems(DiningHallMenu original, DiningHallMenu comparison) {
    Map<DiningHallVenue, List<FoodItem>> uniqueMap = {};

    for (DiningHallVenue venue in original.venues) {
      DiningHallVenue otherVenue;
      for (DiningHallVenue possibleOtherVenue in comparison.venues) {
        if (possibleOtherVenue.name.toLowerCase() == venue.name.toLowerCase()) {
          otherVenue = possibleOtherVenue;
          break;
        }
      }

      if (otherVenue == null) {
        print('Comparison does not have venue ${venue.name}');
        uniqueMap[venue] = List.from(venue.menu);
        continue;
      }

      uniqueMap[venue] = List.from(venue.menu.where((food) => !otherVenue.menu.contains(food)));
    }

    return uniqueMap;
  }

  Future<DiningHallMenu> getComparisonMenu(MenuDate originalDate, Meal meal) {
    MenuDate newDate = new MenuDate(originalDate.time);

    if (originalDate.isToday) {
      newDate.forward();
    } else {
      newDate.now();
    }

    for (int i = 2; i < 7; i++) {
      if (getHoursForMeal(newDate, meal).closed) {
        print('The dining hall is closed for this meal on ${DateUtil.getWeekday(newDate.time)}');
        newDate.forward();
      } else {
        print('The dining hall is open for this meal on ${DateUtil.getWeekday(newDate.time)}');
        break;
      }
    }

    return diningHallProvider.retrieveMenu(this, newDate, meal);
  }

  @override
  String toString() {
    return "DiningHall[$searchName]";
  }
}