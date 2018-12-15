import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/missing_menu_exception.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/structures/menu_selection.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/loading_widget.dart';
import 'package:msu_helper/widgets/material_card.dart';

class MenuDisplay extends StatefulWidget {
    final MenuSelection menuSelection;

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

    MenuDisplay(this.menuSelection);

    @override
    State<StatefulWidget> createState() => new _MenuDisplayState();
}

class _MenuDisplayState extends State<MenuDisplay> {
    Future<List<DiningHallVenue>> sortVenues(DiningHallMenu loadedMenu) async {
        List<DiningHallVenue> venues = loadedMenu.venues;

        if (!settingsProvider.getCached(SettingsConfig.intelligentVenueOrdering)) {
            return venues;
        }

        DiningHallMenu comparisonMenu = await DiningHallMenu.getComparisonMenu(widget.menuSelection);

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
        DiningHallMenu menu = await diningHallProvider.retrieveMenu(widget.menuSelection);

        if (menu == null || menu.venues == null || menu.venues.isEmpty) {
            throw new MissingMenuException(widget.menuSelection);
        }

        List<DiningHallVenue> sortedVenues = await sortVenues(menu);

        return sortedVenues;
    }

    static List<FoodItem> filterDietaryPrefs(DiningHallVenue venue) {
        bool filterGlutenFree = settingsProvider.getCached(SettingsConfig.filterGlutenFreeFoods);
        bool filterVegan = settingsProvider.getCached(SettingsConfig.filterVeganFoods);
        bool filterVegetarian = settingsProvider.getCached(SettingsConfig.filterVegetarianFoods);

        if (!filterGlutenFree && !filterVegan && !filterVegetarian) {
            return venue.menu;
        }

        return venue.menu.where((foodItem) {
            if (filterVegan && !foodItem.preferences.contains('vegan')) {
                return false;
            }

            if (filterVegetarian && !foodItem.preferences.contains('vegetarian')) {
                return false;
            }

            if (filterGlutenFree) {
                bool allowed = true;

                for (var allergen in foodItem.allergens) {
                    allergen = allergen.toLowerCase();

                    if (allergen.contains('gluten') || allergen.contains('wheat')) {
                        allowed = false;
                        break;
                    }
                }

                if (!allowed) {
                    return false;
                }
            }

            return true;
        }).toList();
    }

    Widget buildMenuWidget(List<DiningHallVenue> venues) {
        List<Widget> children = [];

        for (var venue in venues) {
            var filteredMenu = filterDietaryPrefs(venue);

            if (filteredMenu.isEmpty) {
                continue;
            }

            children.add(VenueDisplay(venue, filteredMenu));
        }

        return Column(children: children);
    }

    Widget buildRetryButton() => FlatButton(child: Text('Retry'), onPressed: () => setState(() {}));

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<List<DiningHallVenue>>(
            future: retrieveSortedMenu(),
            builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                    return LoadingWidget(name: 'menu');
                }

                if (snapshot.hasError) {
                    if (snapshot.error is Error) {
                        print((snapshot.error as Error).stackTrace);
                    }
                    print(snapshot.error);

                    if (snapshot.error is MissingMenuException) {
                      return Column(
                        children: <Widget>[
                          ErrorCardWidget('This menu is not posted'),
                          buildRetryButton()
                        ],
                      );
                    }

                    return Column(
                        children: <Widget>[
                            ErrorCardWidget('Could not load menu.'),
                            buildRetryButton()
                        ],
                    );
                }

                return buildMenuWidget(snapshot.data);
            },
        );
    }
}