import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/food_truck/controller.dart' as foodTruckController;
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/home/mini_widget.dart';

class FoodTruckMiniWidget extends StatefulWidget {
  final HomePage homePage;

  FoodTruckMiniWidget(this.homePage);

  @override
  State<StatefulWidget> createState() => new FoodTruckMiniWidgetState();
}

class FoodTruckMiniWidgetState extends Reloadable<FoodTruckMiniWidget> {
  List<String> text = ['Loading...'];
  bool hasFailed = false;

  FoodTruckMiniWidgetState() : super([HomePage.reloadableCategory]) {
    load().catchError((e) {
      print('Could not load food truck data:');
      print(e.toString());
      print((e as Error).stackTrace);

      setState(() {
        text = ['Unable to load food truck information.'];
        hasFailed = true;
      });
    });
  }

  Future load() async {
    List<FoodTruckStop> stops = await foodTruckProvider.retrieveStops();

    if (stops == null || stops.length == 0) {
      setState(() {
        text = ['No stops listed today.'];
      });

      return;
    }

    FoodTruckStop mostRelevant = await foodTruckController.retrieveMostRelevant();

    setState(() {
      text = [
        '${stops.length} stop${stops.length == 1 ? '' : 's'} coming up.'
      ];

      if (mostRelevant != null) {
        text.add('Next is at ${DateUtil.toTimeString(mostRelevant.startDate)} at ${mostRelevant.shortName}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MiniWidget(
      icon: Icons.local_shipping,
      title: 'Food Truck',
      subtitle: 'Delicious food, all on combo!',
      text: text,
      bottomBar: widget.homePage.bottomBar,
      index: 1,
      active: !hasFailed
    );
  }
}