import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';

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
  Widget bodyChild = new Text('Loading...');
  Map<String, Widget> infoWidgets = new Map();
  Map<String, double> infoWidgetPriorities = new Map();

  Future loadTruckInfo() async {
    try {
      FoodTruckResponse truckResponse = await FoodTruckResponse.make();

      setState(() {
        List<FoodTruckStop> stops = new List();

        stops.addAll(truckResponse.stops);
        stops.retainWhere((s) => s.start.difference(new DateTime.now()).inDays == 0);

        Duration timeUntil = new DateTime.now().difference(stops[0].start);

        List<Widget> truckWidgets = new List();

        if (timeUntil.inHours == 0 && !timeUntil.isNegative) {
            String truckText = 'The food truck will be at ${stops[0].location} in ${timeUntil.inMinutes} minute${timeUntil.inMinutes == 1 ? '' : 's'}.';

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

        infoWidgets[Identifiers.FOOD_TRUCK] = new Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            new Container(
              child: new Text('🚚', style: new TextStyle(fontSize: 48.0)),
              padding: new EdgeInsets.all(4.0),
            ),
            new Expanded(child: new Column(children: truckWidgets))
          ]

        );

        if (truckResponse.stops.length == 0) {
          infoWidgetPriorities[Identifiers.FOOD_TRUCK] = Priorities.FOOD_TRUCK;
        } else {
          infoWidgetPriorities[Identifiers.FOOD_TRUCK] = computePriority(base: Priorities.FOOD_TRUCK, when: truckResponse.stops[0].start);
        }
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
        child: new Text('Loading...'),
      );
    } else {
      List<List<dynamic>> entries = MapUtil.getEntries(this.infoWidgetPriorities);

      entries.sort((a, b) => b[1] - a[1]);

      List<Widget> children = new List();

      for (List<dynamic> entry in entries) {
        children.add(infoWidgets[entry[0]]);
      }

      return new Column(
          children: children
      );
    }
  }

  void initState() {
    super.initState();

    this.loadTruckInfo();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            title: TextUtil.getAppBarTitle('Home')
        ),
        body: new Container(
            padding: new EdgeInsets.all(8.0),
            child: this.getBodyChild()
        )
    );
  }
}