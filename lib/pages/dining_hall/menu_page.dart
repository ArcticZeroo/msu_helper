import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/pages/dining_hall/dining_main_page.dart';

class MenuPage extends StatefulWidget {
  final DiningMainPageState diningHallPage;
  final DiningHall diningHall;

  MenuPage(this.diningHallPage, this.diningHall);

  @override
  State<StatefulWidget> createState() => new MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[

      ],
    );
  }
}