import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/widgets/dining_hall/hours_table.dart';

class HallInfoPage extends StatefulWidget {
  final DiningHall diningHall;

  const HallInfoPage(this.diningHall);

  @override
  State<StatefulWidget> createState() => new HallInfoPageState();
}

class HallInfoPageState extends State<HallInfoPage> {
  Widget buildHours() {
    return new Center(
      child: new Column(
        children: <Widget>[
          new Center(
            child: new Text('Hours for ${widget.diningHall.hallName}'),
          ),
          new HoursTable(widget.diningHall)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHours();
  }
}