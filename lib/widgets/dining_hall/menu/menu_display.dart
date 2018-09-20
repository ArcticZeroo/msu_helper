import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/loading_widget.dart';


class MenuDisplay extends StatelessWidget {
  static Map<String, bool> venueCollapseState = {};

  static String cleanVenueName(dynamic venue) {
    String venueName;
    if (venue is DiningHallVenue) {
      venueName = venue.name.toLowerCase();
    } else if (venue is String && venue.isNotEmpty) {
      venueName = venue.toLowerCase();
    } else {
      throw new Exception('Invalid value given for venue');
    }

    return venueName;
  }

  static bool isVenueCollapsed(dynamic venue) {
    return venueCollapseState[cleanVenueName(venue)] ?? false;
  }

  static void setVenueCollapsed(dynamic venue, [bool value]) {
    String venueName = cleanVenueName(venue);
    venueCollapseState[venueName] = value ?? !(isVenueCollapsed(venue));
  }

  final DiningHall diningHall;
  final MenuDate menuDate;
  final Meal meal;

  MenuDisplay({Key key, this.diningHall, this.menuDate, this.meal}) : super(key: key);

  Future<List<DiningHallVenue>> sortVenues(DiningHallMenu loadedMenu) async {
    List<DiningHallVenue> venues = loadedMenu.venues;

    if (!settingsProvider.getCached(SettingsConfig.intelligentVenueOrdering)) {
      return venues;
    }

    DiningHallMenu comparisonMenu = await DiningHallMenu.getComparisonMenu(diningHall, menuDate, meal);

    if (comparisonMenu == null) {
      return venues;
    }

    Map<DiningHallVenue, List<FoodItem>> uniqueItems = DiningHallMenu.findUniqueItems(loadedMenu, comparisonMenu);

    // We're about to sort the list in-place, so don't want to sort the reference
    List<DiningHallVenue> sortedVenues = List.from(venues);

    sortedVenues.sort((a, b) => uniqueItems[b].length - uniqueItems[a].length);

    return sortedVenues;
  }

  Future<List<DiningHallVenue>> retrieveSortedMenu() async {
    DiningHallMenu menu = await diningHallProvider.retrieveMenu(diningHall, menuDate, meal);

    if (menu == null) {
      throw new Exception('null menu was retrieved');
    }

    if (menu.venues == null || menu.venues.isEmpty) {
      throw new Exception('venues for menu are null or empty');
    }

    List<DiningHallVenue> sortedVenues = await sortVenues(menu);

    return sortedVenues;
  }

  Widget buildMenuWidget(List<DiningHallVenue> venues) {
    return new Column(
      children: venues.map((v) => new VenueDisplay(v)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: retrieveSortedMenu(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return new LoadingWidget(name: 'menu');
        }

        if (snapshot.hasError) {
          if (snapshot.error is Error) {
            print((snapshot.error as Error).stackTrace);
          }
          print(snapshot.error);

          return new ErrorCardWidget('Could not load menu.');
        }

        List<DiningHallVenue> venues = snapshot.data as List<DiningHallVenue>;

        return buildMenuWidget(venues);
      },
    );
  }
}