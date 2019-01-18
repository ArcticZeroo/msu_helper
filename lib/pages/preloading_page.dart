import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/movie_night/provider.dart' as movieNightProvider;
import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/preloading/preload_widget.dart';
import 'package:msu_helper/widgets/visibility_toggle.dart';

class PreloadingPage extends StatelessWidget {
  final Map<String, PreloadingWidget> primaryLoaders = {};
  final Map<String, PreloadingWidget> secondaryLoaders = {};

  PreloadingPage() {
    settingsProvider.populate();

    primaryLoaders[Identifier.settings] =
        new PreloadingWidget('Your Settings', settingsProvider.loadAllSettings);
    primaryLoaders[Identifier.foodTruck] = new PreloadingWidget(
        'Food Truck Stops', foodTruckProvider.retrieveStops);
    primaryLoaders[Identifier.foodTruckMenu] = new PreloadingWidget(
        'Food Truck Menus', foodTruckProvider.retrieveMenus);
    primaryLoaders[Identifier.movieNight] = new PreloadingWidget(
        'Movie Night Listings', movieNightProvider.retrieveMovies);
    primaryLoaders[Identifier.diningHall] = new PreloadingWidget(
        'Available Dining Halls + Hours',
        diningHallProvider.retrieveDiningList);

    secondaryLoaders[Identifier.diningHall] =
        new PreloadingWidget('Dining Hall Menus', preloadHallMenus);
  }

  Future preloadPrimary() async {
    print('---------------');
    print('Primary preload initializing...');

    List<Future> loaders = [];

    for (String name in primaryLoaders.keys) {
      loaders.add(primaryLoaders[name].start());
    }

    try {
      await Future.wait(loaders);
    } catch (e) {
      print('Could not load a primary loader');

      if (e is Error) {
        print(e.stackTrace);
      } else {
        print(e.toString());
      }
    }

    print('Primary preload complete');
    print('---------------');
  }

  Future preloadMenusForDay(MenuDate menuDate) async {
    print('Preloading menus for ${menuDate.weekday} from the web');

    try {
      await diningHallProvider.retrieveMenusForDayFromWeb(menuDate);
    } catch (e) {
      throw e;
    }

    print('Preloaded menus for ${menuDate.weekday}');
  }

  Future preloadHallMenus() async {
    print('Preloading secondary data...');

    MenuDate menuDate = MenuDate.now();
    List<Future> menuFutures = <Future>[];

    // For the next 3 days in the week (more can be loaded in demand)
    for (int i = 0; i < 3; i++) {
      menuFutures.add(preloadMenusForDay(menuDate));

      menuDate = menuDate.forward();
    }

    try {
      await Future.wait(menuFutures);

      print('Preloaded all menus');
    } catch (e) {
      print('Could not preload menus:');

      if (e is Error) {
        print(e.stackTrace);
      } else {
        print(e.toString());
      }

      menuFutures.forEach((future) => future.timeout(new Duration()));
    }

    print('Preloaded all dining hall menus.');
  }

  Future preloadSecondary() async {
    print('---------------');
    print('Secondary preload initializing...');

    try {
      await secondaryLoaders[Identifier.diningHall].start();
    } catch (e) {
      print('Loading of dining hall menus failed: $e');
    }

    print('Secondary preload complete');
    print('---------------');
  }

  Future preload() async {
    Future primaryPreloadFuture = preloadPrimary();

    try {
      await primaryLoaders[Identifier.diningHall].future.value;
    } catch (e) {
      // If dining halls did not load, just finish waiting for the rest,
      // and then we can skip the menu loading
      print('Dining halls failed to load, waiting for rest to finish');
      await primaryPreloadFuture;
      return;
    }

    await Future.wait([primaryPreloadFuture, preloadSecondary()]);
  }

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    bool hasGoneHome = false;

    var goHome = () {
      if (hasGoneHome) {
        return;
      }
      openHomePage(context);
      hasGoneHome = true;
    };

    VisibilityToggleWidget skipButton = new VisibilityToggleWidget(
        child: new RaisedButton(
            color: Colors.blue,
            child: new Text('Skip'),
            onPressed: goHome,
            textColor: Colors.white),
        isInitiallyVisible: false);

    List<Widget> columnChildren = <Widget>[
      new Container(
        decoration: new BoxDecoration(
            color: Colors.green[600],
            borderRadius: const BorderRadius.all(const Radius.circular(6.0))),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: new Column(
          children: <Widget>[
            new Text('Pre-loading data...',
                style: new TextStyle(fontSize: 22.0, color: Colors.white)),
            new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text('Shouldn\'t be long!',
                  style: new TextStyle(color: Colors.grey[200])),
            )
          ],
        ),
      ),
      new Card(
        child: new Column(
            children: <Widget>[]
              ..addAll(primaryLoaders.values)
              ..addAll(secondaryLoaders.values)),
      ),
      skipButton
    ];

    primaryLoaders[Identifier.settings].future.addListener(() {
      Future settingsFuture = primaryLoaders[Identifier.settings].future.value;

      settingsFuture.then((v) {
        if (settingsProvider
            .getCached(SettingsConfig.skipPreloadAutomatically)) {
          goHome();
        } else {
          skipButton.isVisible = true;
        }

        return v;
      });
    });

    preload().timeout(new Duration(seconds: 15)).whenComplete(goHome);

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
