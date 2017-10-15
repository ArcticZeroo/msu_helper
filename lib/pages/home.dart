import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
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

  Future loadTruckInfo() async {
    try {
      FoodTruckResponse truckResponse = await FoodTruckResponse.make();

      setState(() {
        List<FoodTruckStop> stops = new List();

        DateTime now = new DateTime.now();

        stops.addAll(truckResponse.stops);
        stops.retainWhere((s) => s.start.day == now.day);

        List<Widget> truckWidgets = new List();

        if (stops.length > 0) {
          Duration timeUntil = (stops.length > 0) ? new DateTime.now().difference(stops[0].start) : new Duration(days: -1);

          if (timeUntil.inHours <= 3 && !timeUntil.isNegative) {
            String truckText = 'The food truck will be at ${stops[0].location} in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m.';

            if (Platform.isAndroid) {
              truckWidgets.add(new Column(
                children: <Widget>[
                  new Text(truckText),
                  new FlatButton(
                    child: new Row(
                        children: <Widget>[
                          new Icon(Icons.location_on),
                          new Text('View in Maps')
                        ]
                    ),
                    onPressed: () async {
                      AndroidIntent androidIntent = new AndroidIntent(
                          action: 'action_view',
                          data: 'https://www.google.com/maps/search/?api=1&query=${stops[0].location.split(' ').join('+')}'
                      );

                      await androidIntent.launch();
                    },
                  )
                ],
              ));
            } else {
              truckWidgets.add(new Text(truckText));
            }
          } else {
            truckWidgets.add(new Text(truckResponse.toString()));
          }

          infoWidgetPriorities[Identifiers.FOOD_TRUCK] = computePriority(base: Priorities.FOOD_TRUCK, when: truckResponse.stops[0].start);
        } else {
          truckWidgets.add(new Text('The food truck has no stops listed for today.'));

          infoWidgetPriorities[Identifiers.FOOD_TRUCK] = Priorities.FOOD_TRUCK * 0.1;
        }

        infoWidgets[Identifiers.FOOD_TRUCK] = new ListTile(
          leading: new CircleAvatar(child: new Text('🚚'), backgroundColor: Colors.transparent),
          title: new Text('MSU Food Truck'),
          subtitle: new Column(children: truckWidgets)
        );
      });
    } catch (e) {
      setState(() {
        infoWidgets[Identifiers.FOOD_TRUCK] = new Column(
            children: <Widget>[
              new Text('Could not load food truck data: ${e.toString()}'),
              new FlatButton(onPressed: loadTruckInfo, child: new Text('Retry'))
            ]
        );

        infoWidgetPriorities[Identifiers.FOOD_TRUCK] = 0.0;
      });
    }
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
        padding: new EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        children: children,
        addRepaintBoundaries: false,
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

    this.loadTruckInfo();
  }

  Widget build(BuildContext context) {
    updateName();

    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: TextUtil.getAppBarTitle('Home'),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.settings), onPressed: () {
              Navigator.pushNamed(context, '/settings');
            })
          ],
        ),
        body: this.getBodyChild()
    );
  }
}