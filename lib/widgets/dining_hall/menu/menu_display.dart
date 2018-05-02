import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';

class MenuDisplay extends StatelessWidget {
  final DiningHallMenu menu;

  MenuDisplay(this.menu);

  @override
  Widget build(BuildContext context) {
    if (menu.closed) {
      return new Center(child: new Text('The dining hall is closed for this meal time.'));
    }

    return new Column(
      children: menu.venues.map((venue) => new VenueDisplay(venue)).toList(),
    );
  }
}