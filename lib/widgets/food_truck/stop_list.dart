import 'package:flutter/material.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/food_truck/menu_display.dart';
import 'package:msu_helper/widgets/food_truck/stop_display.dart';
import 'package:msu_helper/widgets/food_truck/stop_section_title.dart';

class StopListWidget extends StatelessWidget {
  final List<FoodTruckStop> stops;

  const StopListWidget(this.stops);

  static Widget mapStopToDisplay(FoodTruckStop stop) => StopDisplay(stop);

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8.0)
      )
    ];

    DateTime now = DateTime.now();
    List<FoodTruckStop> today = stops.where((stop) => stop.startDate.day == now.day && stop.startDate.month == now.month).toList();
    // Ignore old stops (ones from before today), we only want after today
    List<FoodTruckStop> notToday = stops.where((stop) => !today.contains(stop) && stop.startDate.isAfter(now)).toList();

    if (today.isEmpty && notToday.isEmpty) {
      return new ErrorCardWidget('All stops listed have passed.');
    }

    if (today.isNotEmpty) {
      columnChildren.add(StopSectionTitleWidget('Today'));
      columnChildren.addAll(today.map(mapStopToDisplay));
    }

    if (notToday.isNotEmpty) {
      columnChildren.add(StopSectionTitleWidget('Later This Week'));
      columnChildren.addAll(notToday.map(mapStopToDisplay));
    }

    columnChildren.add(StopSectionTitleWidget('Serving Menus'));
    columnChildren.add(FoodTruckMenuDisplay());

    return ListView(
      scrollDirection: Axis.vertical,
      children: columnChildren,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}