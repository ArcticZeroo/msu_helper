import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/food_truck/stop_display.dart';
import 'package:msu_helper/widgets/loading_widget.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_widget.dart';

class FoodTruckPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FoodTruckPageState();
}

class FoodTruckPageState extends State<FoodTruckPage> {
  Future<List<FoodTruckStop>> _stopLoader;

  @override
  void initState() {
    super.initState();

    _stopLoader = foodTruckProvider.retrieveStops();
  }

  Widget getIconRow(IconData icon, String text) {
    return new Row(children: <Widget>[
      new Container(
        padding: const EdgeInsets.all(4.0),
        child: new Icon(icon, color: Colors.black54),
      ),
      new WrappableWidget(
          new Text(text, style: MaterialCard.subtitleStyle)
      )
    ]);
  }

  Widget buildStop(FoodTruckStop stop) {
    return new StopDisplay(stop);
  }

  Widget buildStopDisplays(List<FoodTruckStop> stops) {
    List<Widget> columnChildren = <Widget>[];

    if (stops == null || stops.length == 0) {
      return new ErrorCardWidget('No stops found.');
    }

    DateTime now = DateTime.now();
    List<FoodTruckStop> today = stops.where((stop) => stop.startDate.day == now.day && stop.startDate.month == now.month).toList();
    // Ignore old stops (ones from before today), we only want after today
    List<FoodTruckStop> notToday = stops.where((stop) => !today.contains(stop) && stop.startDate.isAfter(now)).toList();

    if (today.isEmpty && notToday.isEmpty) {
      return new ErrorCardWidget('All stops listed have passed.');
    }

    final TextStyle titleStyle = const TextStyle(
        fontSize: 24.0,
        color: Colors.black87,
        fontWeight: FontWeight.w500
    );

    if (today.length != 0) {
      columnChildren.add(new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Center(child: new Text('Today', style: titleStyle)),
      ));
      columnChildren.addAll(today.map(buildStop));
    }

    if (notToday.length != 0) {
      columnChildren.add(new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Center(child: new Text('Later This Week', style: titleStyle)),
      ));
      columnChildren.addAll(notToday.map(buildStop));
    }

    columnChildren[0] = new Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: columnChildren.first,
    );

    return new Center(
      child: new Scrollbar(
          child: new RefreshIndicator(
              child: new ListView(
                scrollDirection: Axis.vertical,
                children: columnChildren,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () async {
                try {
                  _stopLoader = foodTruckProvider.retrieveStopsFromWebAndSave();
                  await _stopLoader;
                } catch (e) {
                  print('Could not refresh stops from web:');
                  print(e);
                }

                setState(() {});
              })
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _stopLoader,
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                return new ErrorCardWidget('Could not load food truck data.');
              } else {
                var data = snapshot.data as List<FoodTruckStop>;
                return buildStopDisplays(data);
              }
              break;
            default:
              return new Center(child: new LoadingWidget(name: 'stops'));
          }
        });
  }
}