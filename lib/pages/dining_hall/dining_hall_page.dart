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
import 'package:msu_helper/widgets/dining_hall/menu/venue_display.dart';
import 'package:msu_helper/widgets/error_card.dart';
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
  static final Widget loading = new Center(child: new Text('Loading menu...'));

  Map<String, bool> collapsedState = {};
  MenuDate _date = new MenuDate();
  Meal _selectedMeal;
  DiningHallMenu _menuForMeal;
  DiningHallMenu _comparisonMenu;
  List<DiningHallVenue> _venues;

  bool failed = false;

  void setCollapsed(DiningHallVenue venue, bool isCollapsed) {
    collapsedState[venue.name.toLowerCase()] = isCollapsed;
  }

  bool getCollapsed(DiningHallVenue venue) {
    return collapsedState[venue.name.toLowerCase()] ?? settingsProvider.getCached(SettingsConfig.collapseVenuesByDefault);
  }

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

    if (settingsProvider.getCached(SettingsConfig.intelligentVenueOrdering)) {
      try {
        _comparisonMenu = await widget.diningHall.getComparisonMenu(_date, _selectedMeal);
      } catch (e) {
        print('Could not load comparison menu...');

        if (e is Error) {
          print(e.stackTrace);
        } else {
          print(e);
        }
      }

      if (_comparisonMenu != null) {
        Map<DiningHallVenue, List<FoodItem>> uniqueItems = widget.diningHall.findUniqueItems(_menuForMeal, _comparisonMenu);

        for (DiningHallVenue venue in uniqueItems.keys) {
          print('${venue.name}: ${uniqueItems[venue].length} uniques');
        }

        _venues = List.from(_menuForMeal.venues);
        _venues.sort((a, b) => uniqueItems[b].length - uniqueItems[a].length);
      }
    }

    if (_venues == null) {
      _venues = _menuForMeal.venues;
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
    return widget.diningHall.getHoursForDay(_date);
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

    children.add(new Text('Date: ${DateUtil.formatDateFully(_date.time)}'));
    children.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.lightGreen[900],),
            onPressed: () {
              _date.back();
              loadSelected();
            }),
        new FlatButton(
            onPressed: () {
              _date.now();
              loadSelected();
            },
            child: new Text('Go To Today', style: new TextStyle(color: Colors.green[700]))
        ),
        new IconButton(
            icon: new Icon(Icons.arrow_forward, color: Colors.lightGreen[900]),
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
              loadSelected();
            }
        )
      ],
    ));

    DiningHallHours hoursForMeal = getHoursForMeal();

    if (hoursForMeal.closed) {
      if (_menuForMeal != null && !_menuForMeal.closed) {
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
      }
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
    loadSelected();
  }

  Widget buildMenuItem(int i) {
    if (_menuForMeal.closed) {
      return new ErrorCardWidget('The dining hall is closed for this meal time.');
    }

    return new VenueDisplay(_venues[i], this);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];

    if (settingsProvider.getCached(SettingsConfig.showHallHours)) {
      columnChildren.add(new HoursTable(widget.diningHall));
    }

    columnChildren.add(buildMenuHeader(context));

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
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  UrlUtil.openMapsToLocation(widget.diningHall.hallName);
                },
                tooltip: 'Search in Maps'
            )
          ],
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