import 'package:flutter/material.dart';

class FoodTruckPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FoodTruckPageState();
}

class FoodTruckPageState extends State<FoodTruckPage> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('Food truck!'),
    );
  }
}