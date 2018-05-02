import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/dining_hall/hours_table.dart';
import 'package:msu_helper/widgets/dining_hall/menu/menu_display.dart';
import 'package:msu_helper/widgets/material_card.dart';

import '../../api/dining_hall/provider.dart' as diningHallProvider;

class HallInfoPage extends StatefulWidget {
  final DiningHall diningHall;

  const HallInfoPage(this.diningHall);

  @override
  State<StatefulWidget> createState() => new HallInfoPageState();
}

class HallInfoPageState extends State<HallInfoPage> {
  static final Widget loading = new Center(child: new Text('Loading menu...'));

  MenuDate _date = new MenuDate();
  Meal _selectedMeal;
  DiningHallMenu _menuForMeal;

  bool failed = false;

  Future loadSelected() async {
    if (!diningHallProvider.menuCache.hasValid(
          diningHallProvider.serializeToKey(widget.diningHall, _date, _selectedMeal))) {
      setState(() {
        failed = false;
        _menuForMeal = null;
      });
    }

    try {
      _menuForMeal = await diningHallProvider.retrieveMenu(widget.diningHall, _date, _selectedMeal);
    } catch (e) {
      print('Could not load dining hall menu...');

      if (e is Error) {
        print(e.stackTrace);
      } else {
        print(e);
      }

      setState(() {
        failed = true;
      });

      return;
    }

    setState(() {
      failed = false;
    });
  }

  Future<DateTime> selectTime(BuildContext context) async {
    final DateTime dateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(Duration(days: 7))
    );

    return dateTime;
  }

  List<DiningHallHours> getHoursForDay() {
    return widget.diningHall.hours[DateUtil.getWeekday(_date.time).toLowerCase()];
  }

  DiningHallHours getHoursForMeal([Meal meal]) {
    if (meal == null) {
      meal = _selectedMeal;
    }

    return getHoursForDay()[meal.ordinal];
  }

  Meal findBestMealToday() {
    DiningHallHours mostRelevantHours = MenuDate.getFirstRelevant(getHoursForDay(), TimeOfDay.now());

    return mostRelevantHours?.meal ?? Meal.lunch;
  }

  Widget buildMenuHeader(BuildContext context) {
    List<Widget> children = [];

    children.add(new Text('Date: ${new DateFormat("EEEE, MMMM d'${TextUtil.getOrdinalSuffix(_date.time.weekday)}', y").format(_date.time)}'));
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              _date.back();
              loadSelected();
            }),
        new FlatButton(
            onPressed: () {
              _date.now();
              loadSelected();
            },
            child: new Text('Today')
        ),
        new IconButton(
            icon: new Icon(Icons.arrow_forward),
            onPressed: () {
              _date.forward();
              loadSelected();
            }),
      ],
    ));
    children.add(new Center(
        child: new InkWell(
          onTap: () async {
            DateTime selected = await selectTime(context);

            if (selected != null) {
              _date = new MenuDate(selected);
              loadSelected();
            }
          },
          child: new Row(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(6.0),
                child: new Icon(Icons.today)
              ),
              new Text('Select Date')
            ],
          ),
        )
    ));

    return new Column(
      children: children,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedMeal = findBestMealToday();
    loadSelected();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> viewChildren = [
      new HoursTable(widget.diningHall),
      new Divider(),
      buildMenuHeader(context)
    ];

    if (failed) {
      viewChildren.add(new Center(child: new Text('Could not load menu.')));
    } else if (_selectedMeal == null || _menuForMeal == null) {
      viewChildren.add(loading);
    } else {
      viewChildren.add(new MenuDisplay(_menuForMeal));
    }

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('${widget.diningHall.hallName} - Menu/Hours'),
        ),
        body: new ListView(
          padding: const EdgeInsets.all(12.0),
          children: viewChildren,
        )
    );
  }
}