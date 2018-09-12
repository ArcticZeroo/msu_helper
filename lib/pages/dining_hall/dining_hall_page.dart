import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/UrlUtil.dart';
import 'package:msu_helper/widgets/dining_hall/hours_table.dart';
import 'package:msu_helper/widgets/dining_hall/menu/menu_display_controller.dart';
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/loading_widget.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_widget.dart';
import '../../api/settings/provider.dart' as settingsProvider;

import '../../api/dining_hall/provider.dart' as diningHallProvider;

class HallInfoPage extends StatefulWidget {
  final DiningHall diningHall;

  const HallInfoPage(this.diningHall);

  @override
  State<StatefulWidget> createState() => new HallInfoPageState();
}

class HallInfoPageState extends State<HallInfoPage> {
  MenuDisplayControllerWidget _menuDisplayController;
  MenuDate _selectedDate = new MenuDate();
  Meal _selectedMeal;

  void updateControllerValues() {
    _menuDisplayController.menuDate = _selectedDate;
    _menuDisplayController.meal = _selectedMeal;
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
    return widget.diningHall.getHoursForDay(_selectedDate);
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

    children.add(new Text('Date: ${DateUtil.formatDateFully(_selectedDate.time)}'));
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.lightGreen[900],),
            onPressed: () {
              _selectedDate.back();
              updateControllerValues();
            }),
        new FlatButton(
            onPressed: () {
              _selectedDate.now();
              updateControllerValues();
            },
            child: new Text('Go To Today', style: new TextStyle(color: Colors.green[700]))
        ),
        new IconButton(
            icon: new Icon(Icons.arrow_forward, color: Colors.lightGreen[900]),
            onPressed: () {
              _selectedDate.forward();
              updateControllerValues();
            }),
      ],
    ));
    children.add(new Center(
        child: new InkWell(
          onTap: () async {
            DateTime selected = await selectTime(context);

            if (selected != null) {
              _selectedDate = new MenuDate(selected);
              updateControllerValues();
            }
          },
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.all(6.0),
                  child: new Icon(Icons.today, color: Colors.green[800])
              ),
              new Text('Select Date', style: new TextStyle(color: Colors.green[900]),)
            ],
          ),
        )
    ));
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
            child: new Text('Meal:', style: new TextStyle(color: Colors.green[800])),
            margin: const EdgeInsets.only(right: 8.0)
        ),
        new DropdownButton<Meal>(
            value: _selectedMeal,
            items: Meal.asList().map((meal) => new DropdownMenuItem(
                child: new Text(meal.name, style: new TextStyle(color: Colors.lightGreen[900])),
                value: meal)
            ).toList(),
            onChanged: (Meal selected) {
              _selectedMeal = selected;
              updateControllerValues();
            }
        )
      ],
    ));

    DiningHallHours hoursForMeal = getHoursForMeal();

    if (hoursForMeal.closed) {
      //TODO: Fix this!
      /*if (_menuForMeal != null && !_menuForMeal.closed) {
        children.add(new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: new Icon(Icons.warning, color: Colors.deepOrange),
            ),
            new WrappableWidget(new Text('The dining hall\'s schedule suggests that it is closed for this meal time.'))
          ],
        ));
      }*/
    } else {
      List<String> mealServingText = [];
      String startString = DateUtil.formatTimeOfDay(hoursForMeal.beginTime);
      String endString = DateUtil.formatTimeOfDay(hoursForMeal.endTime);

      if (hoursForMeal.isNow()) {
        mealServingText.add('This meal is currently being served from $startString to $endString');
      } else {
        mealServingText.add('This meal will be served from $startString to $endString');
      }

      if (hoursForMeal.limitedMenuBegin != null && hoursForMeal.limitedMenuBegin != -1) {
        if (hoursForMeal.isLimitedMenu) {
          mealServingText.add('This meal is served with a limited menu.');
        } else {
          mealServingText.add('This meal serves limited menu from ${DateUtil.formatTimeOfDay(hoursForMeal.limitedMenuTime)} to $endString');
        }
      }

      if (hoursForMeal.grillClosesAt != null && hoursForMeal.grillClosesAt != -1) {
        if (hoursForMeal.isGrillClosed) {
          mealServingText.add('The grill is closed during this meal.');
        } else {
          mealServingText.add('The grill closes during this meal from ${DateUtil.formatTimeOfDay(hoursForMeal.limitedMenuTime)} to $endString');
        }
      }

      if (hoursForMeal.closeTimes != null && hoursForMeal.closeTimes.length != 0) {
        for (var closingName in hoursForMeal.closeTimes.keys) {
          mealServingText.add('$closingName will close at ${DateUtil.formatTimeOfDay(hoursForMeal.closeTimes[closingName])}');
        }
      }

      if (hoursForMeal.openTimes != null && hoursForMeal.openTimes.length != 0) {
        for (var openingName in hoursForMeal.openTimes.keys) {
          mealServingText.add('$openingName will open at ${DateUtil.formatTimeOfDay(hoursForMeal.openTimes[openingName])}');
        }
      }

      children.add(new Column(
        children: mealServingText.map((s) => new Text(s)).toList(),
      ));
    }

    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: new MaterialCard(
        backgroundColor: Colors.green[100],
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
    _menuDisplayController = new MenuDisplayControllerWidget(
      diningHall: widget.diningHall,
      menuDate: _selectedDate,
      meal: _selectedMeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];

    if (settingsProvider.getCached(SettingsConfig.showHallHours)) {
      columnChildren.add(new HoursTable(widget.diningHall));
    }

    columnChildren.add(buildMenuHeader(context));
    columnChildren.add(_menuDisplayController);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('${widget.diningHall.hallName} - Menu/Hours'),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  UrlUtil.openMapsToLocation(widget.diningHall.hallName);
                },
                tooltip: 'Open in Maps'
            )
          ],
        ),
        body: new ListView(children: columnChildren)
    );
  }
}