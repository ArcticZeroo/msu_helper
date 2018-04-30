import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';

class HallInfoPage extends StatefulWidget {
  final DiningHall diningHall;

  const HallInfoPage(this.diningHall);

  @override
  State<StatefulWidget> createState() => new HallInfoPageState();
}

class HallInfoPageState extends State<HallInfoPage> {
  Widget buildHours() {
    List<Widget> children = <Widget>[
      new Center(
        child: new Text('Hours for ${widget.diningHall.hallName}'),
      )
    ];

    List<TableRow> tableRows = <TableRow>[];

    for (String day in widget.diningHall.hours.keys) {

    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  }
}