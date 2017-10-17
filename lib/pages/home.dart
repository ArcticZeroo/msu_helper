import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
import 'package:msu_helper/api/movies.dart';
import 'package:msu_helper/util/AndroidUtil.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/WidgetUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/TextUtil.dart';
import '../util/MapUtil.dart';
import '../api/foodtruck.dart';
import '../api/priority.dart';
import '../config/Identifiers.dart';
import '../config/Priorities.dart';

class Homepage extends StatefulWidget {
  createState() => new _HomepageState();
}

class _HomepageState extends State<Homepage> {
  SharedPreferences sharedPreferences;
  Widget welcomeWidget;
  Map<String, Widget> infoWidgets = new Map();
  Map<String, double> infoWidgetPriorities = new Map();

  Future loadTruckInfo([bool refresh = false]) async {
    try {
      FoodTruckResponse truckResponse = await FoodTruckResponse.make(refresh);

      List<FoodTruckStop> stops = new List();

      DateTime now = new DateTime.now();

      stops.addAll(truckResponse.stops);
      stops.retainWhere((s) => !s.isCancelled && s.start.day == now.day);

      List<Widget> truckWidgets = new List();
      List<Widget> truckBadWidgets = new List();

      if (stops.length > 0) {
        DateTime now = new DateTime.now();

        for (FoodTruckStop stop in stops) {
          Widget leading = (Platform.isAndroid)
              ? new Icon(Icons.location_on)
              : new Icon(Icons.timer);

          Widget title;

          Duration timeUntil = stop.start.difference(now);

          // Truck is gone
          if (stop.end.isBefore(now)) {
            truckBadWidgets.add(new ListTile(
              leading: new Icon(Icons.mood_bad),
              title: new Text('It left ${stop.location} at ${DateUtil.toTimeString(stop.end)}.'),
            ));
            continue;
          }
          // Truck is here now
          else{
            if (stop.start.isBefore(now) && stop.end.isAfter(now)) {
              title = new Text('It is currently at ${stop.location} until ${DateUtil.toTimeString(stop.end)}.');
            } else {
              // Truck will be here soon
              title = new Text('It will be at ${stop.location} from ${DateUtil.toTimeString(stop.start)} until ${DateUtil.toTimeString(stop.end)} (${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m from now).');
            }

            if (Platform.isAndroid) {
              truckWidgets.add(new ListTile(
                leading: leading,
                title: title,
                onTap: () async {
                  if (Platform.isAndroid) {
                    await AndroidUtil.openMaps(stop.mapsLocation);
                  }
                },
              ));
            } else {
              truckWidgets.add(new ListTile(
                  leading: leading,
                  title: title
              ));
            }
          }
        }

        infoWidgetPriorities[Identifiers.FOOD_TRUCK] = computePriority(base: Priorities.FOOD_TRUCK, when: stops[0].start);
      } else {
        infoWidgetPriorities[Identifiers.FOOD_TRUCK] = Priorities.FOOD_TRUCK * 0.1;
      }

      List<Widget> cardChildren = <Widget>[
        new ListTile(
            leading: new CircleAvatar(child: new Text('🚚'), backgroundColor: Colors.transparent),
            title: new Text('MSU Food Truck'),
            subtitle: new Text('The food truck has ${stops.length == 0 ? 'no' : stops.length} stop${stops.length == 1 ? '' : 's'} today.')
        )
      ];

      cardChildren.addAll(truckWidgets);
      cardChildren.addAll(truckBadWidgets);

      infoWidgets[Identifiers.FOOD_TRUCK] = new Container(
          padding: new EdgeInsets.all(16.0),
          child: new Column(children: cardChildren)
      );
    } catch (e) {
      infoWidgets[Identifiers.FOOD_TRUCK] = new Container(
        padding: new EdgeInsets.all(16.0),
        child: new Column(
            children: <Widget>[
              new Text('Could not load food truck data: ${e.toString()}'),
              new FlatButton(onPressed: loadTruckInfo, child: new Text('Retry'))
            ]
        ),
      );

      infoWidgetPriorities[Identifiers.FOOD_TRUCK] = 0.0;
    }
  }

  Future loadMovieInfo([bool refresh = false]) async {
    List<Movie> movies = await MovieNightResponse.get(refresh);

    List<Widget> movieWidgets = <Widget>[
     new ListTile(
       leading: new Icon(Icons.local_movies),
       title: new Text('RHA Movie Night'),
       subtitle: new Text('This week, ${movies.length} movie${movies.length == 1 ? '' : 's'} will be playing at Campus Center Cinemas.')
     )
    ];

    infoWidgets[Identifiers.MOVIE_NIGHT] = new Container(
      padding: new EdgeInsets.all(16.0),
      child: new Column(
        children: movieWidgets,
      ),
    );

    infoWidgetPriorities[Identifiers.MOVIE_NIGHT] = 1.0;
  }

  Future loadPageData([bool refresh = false]) async {
    await loadTruckInfo(refresh);
    await loadMovieInfo(refresh);
    setState(() {});
  }

  Widget getBodyChild() {
    if (this.infoWidgets.length == 0) {
      return new Center(
        child: new Column(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Container(
              padding: new EdgeInsets.all(8.0),
              child: new Text('Loading...'),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      );
    } else {
      List<List<dynamic>> entries = MapUtil.getEntries(this.infoWidgetPriorities);

      entries.sort((a, b) => b[1] - a[1]);

      List<Widget> children = new List();

      children.add(welcomeWidget ?? new Text(''));

      for (List<dynamic> entry in entries) {
        children.add(infoWidgets[entry[0]]);
      }

      return new ListView(
        scrollDirection: Axis.vertical,
        children: ListTile.divideTiles(tiles: children, color: Colors.black45).toList(),
        addRepaintBoundaries: false
      );
    }
  }

  void updateName() {
    if (this.sharedPreferences == null) {
      return;
    }

    String userName = this.sharedPreferences.getString(Identifiers.USER_NAME_STORAGE);

    welcomeWidget = new Container(
      padding: new EdgeInsets.all(12.0),
      child: new Center(
        child: new Text(
          userName == null ? 'You don\'t have a name set. Open the settings to change that!' : 'Welcome, $userName',
          style: new TextStyle(
              fontSize: 18.0
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance()
      .then((SharedPreferences preferences) {
        this.sharedPreferences = preferences;

        setState(() {});
      })
      .catchError((e) {});

    loadPageData();
  }

  Widget build(BuildContext context) {
    updateName();

    return new Scaffold(
        appBar: new AppBar(
          leading: new CircleAvatar(),
          title: TextUtil.getAppBarTitle('Home'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () async {
                // Clear all existing widgets
                this.infoWidgets.clear();
                this.infoWidgetPriorities.clear();

                // Set state to get loading icon
                setState(() {});

                // Get page info with refresh set to true
                await loadPageData(true);
              },
            ),
            new IconButton(icon: new Icon(Icons.settings), onPressed: () {
              Navigator.pushNamed(context, '/settings');
            })
          ],
        ),
        body: this.getBodyChild()
    );
  }
}