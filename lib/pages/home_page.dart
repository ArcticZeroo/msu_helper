import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';
import 'package:msu_helper/widgets/home/dining_hall.dart';
import 'package:msu_helper/widgets/home/food_truck.dart';
import 'package:msu_helper/widgets/home/movie_night.dart';

class HomePage extends StatefulWidget {
  static const String reloadableCategory = 'homepage_miniwidget';
  final MainBottomBar bottomBar;

  HomePage(this.bottomBar);

  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('Building homepage');
    return new Center(
      // This is a column instead of a ListView since I want it to be centered
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: new Text('Tap one of the below widgets to visit its page!'),
          ),
          new FoodTruckMiniWidget(widget),
          new DiningHallMiniWidget(widget),
          new MovieNightMiniWidget(widget)
        ],
      ),
    );
  }
}