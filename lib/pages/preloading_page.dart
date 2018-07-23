import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/preloading/preload_widget.dart';

import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/time.dart';

import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/movie_night/provider.dart' as movieNightProvider;

class PreloadingPage extends StatelessWidget {
  final Map<String, PreloadingWidget> primaryLoaders = {};
  final Map<String, PreloadingWidget> secondaryLoaders = {};

  PreloadingPage() {
    settingsProvider.populate();

    primaryLoaders[Identifier.settings] = new PreloadingWidget('Your Settings', settingsProvider.loadAllSettings);
    primaryLoaders[Identifier.foodTruck] = new PreloadingWidget('Food Truck Stops', foodTruckProvider.retrieveStops);
    primaryLoaders[Identifier.movieNight] = new PreloadingWidget('Movie Night Listings', movieNightProvider.retrieveMovies);
    primaryLoaders[Identifier.diningHall] = new PreloadingWidget('Available Dining Halls + Hours', diningHallProvider.retrieveDiningList);

    secondaryLoaders[Identifier.diningHall] = new PreloadingWidget('Dining Hall Menus', () async {
      print('Preloading secondary data...');

      List<DiningHall> diningHalls = await diningHallProvider.retrieveDiningList();

      MenuDate menuDate = new MenuDate();

      // For the next 3 days in the week (more can be loaded in demand)
      for (int i = 0; i < 3; i++) {
        List<Future> menuFutures = <Future>[];

        // Load every dining hall's menus on this day
        for (DiningHall diningHall in diningHalls) {
          // For every meal this dining hall serves on this day
          for (Meal meal in Meal.asList()) {
            // Add it to the list without awaiting so we can do lots of requests in a short amount of time
            // No need to catch yet, since we will await it in a second
            menuFutures.add(diningHallProvider.retrieveMenu(diningHall, menuDate, meal));
          }
        }

        try {
          await Future.wait(menuFutures);

          print('Preloaded all menus for ${menuDate.weekday}');
        } catch (e) {
          print('Could not preload menus for ${menuDate.weekday}');

          if (e is Error) {
            print(e.stackTrace);
          }

          menuFutures.forEach((future) => future.timeout(new Duration()));
        }

        menuDate.forward();
      }

      print('Preloaded all dining hall menus.');
    });
  }

  Future preloadPrimary() async {
    List<Future> primaryFutures = [];

    for (String name in primaryLoaders.keys) {
      print('Preloading data for $name...');
      primaryFutures.add(
          primaryLoaders[name].start()
              .catchError((e) => print('Could not preload data for $name: $e'))
      );
    }

    try {
      await Future.wait(primaryFutures);
    } catch (e) {
      print('Loading failed for a future');
    }
  }

  Future preloadSecondary() async {
    try {
      await secondaryLoaders[Identifier.diningHall].start();
    } catch (e) {
      print('Loading of dining hall menus failed: $e');
    }
  }

  Future preload() async {
    await preloadPrimary();

    try {
      await primaryLoaders[Identifier.diningHall].future.value;
    } catch (e) {
      return;
    }

    await preloadSecondary();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[
      new Container(
        decoration: new BoxDecoration(
          color: Colors.green[600],
          borderRadius: const BorderRadius.all(const Radius.circular(6.0))
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: new Column(
          children: <Widget>[
            new Text('Pre-loading data...', style: new TextStyle(fontSize: 22.0, color: Colors.white)),
            new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text('Shouldn\'t be long!', style: new TextStyle(color: Colors.grey[200])),
            )
          ],
        ),
      ),
      new Card(
        child: new Column(
          children: primaryLoaders.values.toList()..addAll(secondaryLoaders.values),
        ),
      )
    ];

    preload().timeout(new Duration(seconds: 15)).then((_) {
      Navigator.of(context).pushReplacementNamed('home');
    });

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: Colors.grey[200]),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: columnChildren,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}