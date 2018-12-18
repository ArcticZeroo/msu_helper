import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';

typedef void OnChangeCallback<T>(T value);

class MenuPageHeader extends StatefulWidget {
  final DiningHall diningHall;
  final Meal initialMeal;
  final MenuDate initialDate;
  final OnChangeCallback<MenuDate> onDateChange;
  final OnChangeCallback<Meal> onMealChange;

  MenuPageHeader({
    @required
    this.diningHall,
    @required
    this.initialDate,
    @required
    this.initialMeal,
    @required
    this.onDateChange,
    @required
    this.onMealChange
  });

  Future<DateTime> selectTime(BuildContext context) async {
    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: initialDate.time,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 7))
    );

    return dateTime;
  }

  @override
  State<StatefulWidget> createState() => MenuPageHeaderState();
}

class MenuPageHeaderState extends State<MenuPageHeader> {
  Meal _selectedMeal;
  MenuDate _selectedDate;

  @override
  void initState() {
    _selectedMeal = widget.initialMeal;
    _selectedDate = widget.initialDate;

    super.initState();
  }

  void changeDate(MenuDate date) {
    setState(() {
      _selectedDate = date;
    });

    widget.onDateChange(date);
  }

  void changeMeal(Meal meal) {
    setState(() {
      _selectedMeal = meal;
    });

    widget.onMealChange(meal);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(new Text('Date: ${DateUtil.formatDateFully(_selectedDate.time)}'));
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.lightGreen[900],),
          onPressed: () {
            changeDate(_selectedDate.back());
          }),
        new FlatButton(
          onPressed: () {
            changeDate(MenuDate.now());
          },
          child: new Text('Go To Today', style: new TextStyle(color: Colors.green[700]))
        ),
        new IconButton(
          icon: new Icon(Icons.arrow_forward, color: Colors.lightGreen[900]),
          onPressed: () {
            changeDate(_selectedDate.forward());
          },
        )
      ],
    ));
    children.add(new Center(
      child: new InkWell(
        onTap: () async {
          DateTime selected = await widget.selectTime(context);

          if (selected != null && _selectedDate.time != selected) {
            changeDate(new MenuDate(selected));
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
            if (_selectedMeal.ordinal == selected.ordinal) {
              return;
            }

            changeMeal(selected);
          }
        )
      ],
    ));

    DiningHallHours hoursForMeal = widget.diningHall.getHoursForMeal(_selectedDate, _selectedMeal);

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

      if (hoursForMeal.closeTimes != null && hoursForMeal.closeTimes.isNotEmpty) {
        for (var closingName in hoursForMeal.closeTimes.keys) {
          mealServingText.add('$closingName will close at ${DateUtil.formatTimeOfDay(hoursForMeal.closeTimes[closingName])}');
        }
      }

      if (hoursForMeal.openTimes != null && hoursForMeal.openTimes.isNotEmpty) {
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
}