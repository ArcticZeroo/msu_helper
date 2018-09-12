import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';

import '../provider.dart' as diningHallProvider;

part './dining_hall_menu.g.dart';

@JsonSerializable()
class DiningHallMenu extends Object with _$DiningHallMenuSerializerMixin {
  @JsonKey(ignore: true)
  final DiningHall diningHall;

  DiningHallMenu({
    this.closed, this.venues, this.diningHall
  });

  final bool closed;
  final List<DiningHallVenue> venues;

  factory DiningHallMenu.fromJson(Map<String, dynamic> json) => _$DiningHallMenuFromJson(json);

  DiningHallMenu copyWith({ bool closed, List<DiningHallVenue> venues, DiningHall diningHall }) {
    return new DiningHallMenu(
      closed: closed ?? this.closed,
      venues: venues ?? this.venues,
      diningHall: diningHall ?? this.diningHall
    );
  }

  static Future<DiningHallMenu> getComparisonMenu(DiningHall diningHall, MenuDate originalDate, Meal meal) {
    MenuDate newDate = new MenuDate(originalDate.time);

    if (originalDate.isToday) {
      newDate.forward();
    } else {
      newDate.now();
    }

    for (int i = 2; i < 7; i++) {
      if (diningHall.getHoursForMeal(newDate, meal).closed) {
        print('The dining hall is closed for this meal on ${DateUtil.getWeekday(newDate.time)}');
        newDate.forward();
      } else {
        print('The dining hall is open for this meal on ${DateUtil.getWeekday(newDate.time)}');
        break;
      }
    }

    return diningHallProvider.retrieveMenu(diningHall, newDate, meal);
  }

  static Map<DiningHallVenue, List<FoodItem>> findUniqueItems(DiningHallMenu original, DiningHallMenu comparison) {
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
}