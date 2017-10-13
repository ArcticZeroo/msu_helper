import 'dart:async';

import 'package:flutter/material.dart';

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
    print('getting food truck info...');
    try {
      FoodTruckResponse truckResponse = await FoodTruckResponse.make();

      print('done! response loaded');

      setState(() {
          print('setting state...');
          infoWidgets[Identifiers.FOOD_TRUCK] = new Text(truckResponse.toString());

          print('${truckResponse.stops.length} stop(s)');
          if (truckResponse.stops.length == 0) {
            infoWidgetPriorities[Identifiers.FOOD_TRUCK] = Priorities.FOOD_TRUCK;
          } else {
            infoWidgetPriorities[Identifiers.FOOD_TRUCK] = computePriority(base: Priorities.FOOD_TRUCK, when: truckResponse.stops[0].start);
          }

          print('priority: ${infoWidgetPriorities[Identifiers.FOOD_TRUCK]}');
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