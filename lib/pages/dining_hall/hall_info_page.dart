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
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          child: new Text('Meal:'),
          margin: const EdgeInsets.only(right: 8.0)
        ),
        new DropdownButton<Meal>(
            value: _selectedMeal,
            items: Meal.asList().map((meal) => new DropdownMenuItem(
                child: new Text(meal.name),
                value: meal)
            ).toList(),
            onChanged: (Meal selected) {
              _selectedMeal = selected;
              loadSelected();
            }
        )
      ],
    ));

    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: new MaterialCard(
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedMeal = findBestMealToday();
    loadSelected();
  }

  Widget buildMenuItem(int i) {
    print('Building menu item index $i');

    if (_menuForMeal.closed) {
      return new Center(child: new Text('The dining hall is closed for this meal time.'));
    }

    VenueDisplay display = new VenueDisplay(_menuForMeal.venues[i]);

    if (getHoursForMeal().closed) {
      return new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(right: 8.0),
                child: new Icon(Icons.warning),
              ),
              new Center(child: new Text('The dining hall\'s schedule suggests that it is closed for this meal time.'))
            ],
          ),
          display
        ]
      );
    }

    return display;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      new HoursTable(widget.diningHall),
      buildMenuHeader(context),
    ];

    int items;
    if (failed) {
      columnChildren.add(new Center(child: new Text('Could not load menu.')));
      items = columnChildren.length;
    } else if (_selectedMeal == null || _menuForMeal == null) {
      columnChildren.add(loading);
      items = columnChildren.length;
    } else {
      items = (_menuForMeal.closed) ? columnChildren.length + 1 : _menuForMeal.venues.length + columnChildren.length;
    }

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('${widget.diningHall.hallName} - Menu/Hours'),
        ),
        body: new ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          itemCount: items,
          itemBuilder: (context, i) {
            if (i < columnChildren.length) {
              return columnChildren[i];
            }

            return buildMenuItem(i - columnChildren.length);
          },
        )
    );
  }
}