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
    return new Container(
      margin: const EdgeInsets.all(12.0),
      child: new HoursTable(widget.diningHall)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${widget.diningHall.hallName} - Menu/Hours'),
      ),
      body: new Column(
        children: <Widget>[
          buildHours()
        ],
      )
    );
  }
}