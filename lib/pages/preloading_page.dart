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

  PreloadingPage() {
    primaryLoaders[Identifier.foodTruck] = new PreloadingWidget('Food Truck Stops', foodTruckProvider.retrieveStops);
    primaryLoaders[Identifier.movieNight] = new PreloadingWidget('Movie Night Listings', movieNightProvider.retrieveMovies);
    primaryLoaders[Identifier.diningHall] = new PreloadingWidget('Available Dining Halls + Hours', diningHallProvider.retrieveDiningList);
  }

  Future preloadSingle(PreloadingWidget widget) {
    var completer = new Completer();

    onStatusChange() {
      FutureStatus newStatus = widget.status.value;

      print('Status has been changed to ' + newStatus.toString());

      if (newStatus == FutureStatus.done) {
        completer.complete();
      } else if (newStatus == FutureStatus.failed) {
        completer.completeError(null);
      } else {
        return;
      }

      widget.status.removeListener(onStatusChange);
    }

    widget.status.addListener(onStatusChange);

    if (widget.status.value.index > FutureStatus.preload.index) {
      onStatusChange();
    } else {
      widget.status.value = FutureStatus.preload;
    }

    return completer.future;
  }

  Future preload() async {
    List<Future> primaryFutures = [];

    for (String name in primaryLoaders.keys) {
      print('Preloading data for $name...');
      primaryFutures.add(
          preloadSingle(primaryLoaders[name])
          .catchError((e) => print('Could not preload data for $name'))
      );
    }

    try {
      await Future.wait(primaryFutures);
    } catch (e) {
      print('Loading failed for a future');
    }
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
            new Text('Loading data from MSU...', style: new TextStyle(fontSize: 22.0, color: Colors.white)),
            new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text('Shouldn\'t be long!', style: new TextStyle(color: Colors.grey[200])),
            )
          ],
        ),
      ),
      new Card(
        child: new Column(
          children: primaryLoaders.values.toList(),
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