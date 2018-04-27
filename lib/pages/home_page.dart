import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';
import 'package:msu_helper/widgets/home/food_truck.dart';

class HomePage extends StatefulWidget {
  final MainBottomBar bottomBar;

  HomePage(this.bottomBar);

  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new ListView(
        children: <Widget>[
          new FoodTruckMiniWidget(widget)
        ],
      ),
    );
  }
}