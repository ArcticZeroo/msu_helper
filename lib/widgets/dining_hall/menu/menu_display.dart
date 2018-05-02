import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';

class MenuDisplay extends StatelessWidget {
  final DiningHall diningHall;
  final Meal meal;
  final MenuDate menuDate;
  final DiningHallMenu menu;

  MenuDisplay({
    this.diningHall,
    this.meal,
    this.menuDate,
    this.menu
  });

  @override
  Widget build(BuildContext context) {
    if (menu.closed) {
      return new Center(child: new Text('The dining hall is closed for this meal time.'));
    }

    if (diningHall.hours[DateUtil.getWeekday(menuDate.time).toLowerCase()][meal.ordinal].closed) {
      //return new Center(child: new Text('The dining hall is closed for this meal time.'));
    }

    return new Expanded(
      child: new ListView.builder(
        itemCount: menu.venues.length,
        itemBuilder: (context, i) => new VenueDisplay(menu.venues[i])
      ),
    );
  }
}