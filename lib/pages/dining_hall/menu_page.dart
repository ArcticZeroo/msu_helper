import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/structures/menu_selection.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/UrlUtil.dart';
import 'package:msu_helper/widgets/dining_hall/hours_table.dart';
import 'package:msu_helper/widgets/dining_hall/menu/menu_display.dart';
import 'package:msu_helper/widgets/dining_hall/menu/menu_page_header.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/material_card.dart';

import '../../api/settings/provider.dart' as settingsProvider;

class HallInfoPage extends StatefulWidget {
  final DiningHall diningHall;

  const HallInfoPage(this.diningHall);

  @override
  State<StatefulWidget> createState() => new HallInfoPageState();
}

class HallInfoPageState extends State<HallInfoPage> {
  Widget _menuDisplay;
  Meal _selectedMeal;
  MenuDate _selectedDate;

  void createMenuDisplay() {
    if (getHoursForMeal().closed) {
      _menuDisplay = new ErrorCardWidget('The dining hall is closed for this mealtime.');
      return;
    }

    _menuDisplay = new MenuDisplay(MenuSelection(
      diningHall: widget.diningHall,
      meal: _selectedMeal,
      date: _selectedDate
    ));
  }

  void updateMenuDisplay() {
    setState(() {
      createMenuDisplay();
    });
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

  @override
  void initState() {
    super.initState();

    _selectedDate = MenuDate.now();
    _selectedMeal = widget.diningHall.getBestMealToday();
    createMenuDisplay();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];

    if (settingsProvider.getCached(SettingsConfig.showHallHours)) {
      columnChildren.add(new HoursTable(widget.diningHall));
    }

    columnChildren.add(MenuPageHeader(
      diningHall: widget.diningHall,
      initialDate: _selectedDate,
      initialMeal: _selectedMeal,
      onDateChange: (MenuDate date) {
        setState(() {
          _selectedDate = date;
        });
      },
      onMealChange: (Meal meal) {
        setState(() {
          _selectedMeal = meal;
        });
      }
    ));
    columnChildren.add(_menuDisplay);

    return new Scaffold(
        appBar: AppBar(
          title: Text('${widget.diningHall.hallName} - Menu/Hours'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  UrlUtil.openMapsToLocation(widget.diningHall.hallName);
                },
                tooltip: 'Open in Maps'
            )
          ],
        ),
        body: ListView(children: columnChildren)
    );
  }
}