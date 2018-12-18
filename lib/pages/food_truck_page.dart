import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/food_truck/menu_display.dart';
import 'package:msu_helper/widgets/food_truck/stop_display.dart';
import 'package:msu_helper/widgets/food_truck/stop_list.dart';
import 'package:msu_helper/widgets/loading_widget.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_widget.dart';

class FoodTruckPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FoodTruckPageState();
}

class FoodTruckPageState extends State<FoodTruckPage> {
  final TextStyle titleStyle = const TextStyle(
    fontSize: 24.0,
    color: Colors.black87,
    fontWeight: FontWeight.w500
  );

  Future<List<FoodTruckStop>> _stopLoader;

  @override
  void initState() {
    super.initState();

    _stopLoader = foodTruckProvider.retrieveStops();
  }

  Widget buildStopList(List<FoodTruckStop> stops) {
    if (stops == null || stops.isEmpty) {
      return MaterialCard(
        body: Text('No stops are currently listed')
      );
    }

    return Scrollbar(
      child: RefreshIndicator(
        child: StopListWidget(stops),
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
    );
  }

  @override
  Widget build(BuildContext context) => new FutureBuilder<List<FoodTruckStop>>(
    future: _stopLoader,
    builder: (ctx, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return ErrorCardWidget('Could not load food truck data...');
        }

        return Center(
          child: buildStopList(snapshot.data),
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LoadingWidget(name: 'stops')
        ]
      );
    });
}