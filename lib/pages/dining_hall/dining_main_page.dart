import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/provider.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/pages/dining_hall/hall_info_page.dart';

class DiningMainPage extends StatefulWidget {
  static const String reloadableCategory = 'dining_info';

  @override
  State<StatefulWidget> createState() => new DiningMainPageState();
}

class DiningMainPageState extends Reloadable<DiningMainPage> {
  List<DiningHall> diningHalls;
  DateTime _selectedTime;
  bool failed = false;

  DateTime get selectedTime => _selectedTime;

  Future<DateTime> selectTime(BuildContext context) async {
    final DateTime dateTime = await showDatePicker(
        context: context,
        initialDate: _selectedTime ?? DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(Duration(days: 7))
    );

    if (dateTime == null) {
      return _selectedTime;
    }

    _selectedTime = dateTime;

    return dateTime;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    try {
      diningHalls = await retrieveDiningList();
    } catch (e) {
      setState(() {
        failed = true;
      });
      return;
    }

    setState(() {
      failed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return new Center(
        child: new Text('Could not load dining hall information.'),
      );
    }

    if (diningHalls == null) {
      return new Center(
        child: new Text('Loading dining halls...'),
      );
    }

    return new Column(
      children: <Widget>[
        new Center(
          child: new Text('Tap a dining hall to see its menu and hours!')
        ),
        new Column(
          children: diningHalls.map((diningHall) => new ListTile(
            leading: new Icon(Icons.restaurant),
            title: new Text(diningHall.hallName),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new HallInfoPage(diningHall))
              );
            },
          )).toList(),
        )
      ],
    );
  }
}