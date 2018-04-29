import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/dining_hall//provider.dart' as diningHallProvider;
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/config/settings.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/pages/settings_page.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/home/mini_widget.dart';

class DiningHallMiniWidget extends StatefulWidget {
  final HomePage homePage;

  DiningHallMiniWidget(this.homePage);

  @override
  State<StatefulWidget> createState() => new _DiningHallMiniWidgetState();
}

class _DiningHallMiniWidgetState extends Reloadable<DiningHallMiniWidget> {
  DiningHall favoriteHall;
  List<String> text = ['Loading...'];
  bool hasFailed = false;

  _DiningHallMiniWidgetState()
      : super([HomePage.reloadableCategory, SettingsPage.reloadableCategory]) {
    load();
  }

  load() {
    _retrieveDataAndUpdate().catchError((e) {
      print('Could not load dining hall data:');
      print(e.toString());
      print((e as Error).stackTrace);

      setState(() {
        text = ['Unable to load dining hall information.'];
        hasFailed = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    addSettingListener(SettingsConfig.favoriteDiningHall, () {
      load();
    });
  }

  String _formatOpenNext(MenuDate menuDate, DiningHallHours mealHours) {
    return 'It opens for ${mealHours.meal.name} '
        'on ${DateUtil.getWeekday(menuDate.time)} '
        'at ${DateUtil.formatTimeOfDay(mealHours.beginTime)}';
  }

  Future _retrieveDataAndUpdate() async {
    favoriteHall = await retrieveFavoriteHall();

    if (favoriteHall == null) {
      setState(() {
        text = ['You don\'t have a favorite hall set! Add one in the settings.'];
      });
      return;
    }

    text = ['Your favorite: ${favoriteHall.hallName}'];

    MenuDate menuDate = new MenuDate();
    List<DiningHallHours> hoursToday = menuDate.getDayHours(favoriteHall);

    // If it's closed today
    if (DiningHallHours.isFullyClosed(hoursToday)) {
      text.add('It\'s closed today.');

      for (int i = 1; i < 7; i++) {
        menuDate.forward();

        List<DiningHallHours> nextHours = menuDate.getDayHours(favoriteHall);
        if (!DiningHallHours.isFullyClosed(nextHours)) {
          DiningHallHours relevant = MenuDate.getFirstRelevant(
              nextHours,
              new TimeOfDay(hour: 0, minute: 0)
          );

          if (relevant != null) {
            setState(() {
              text.add(_formatOpenNext(menuDate, relevant));
            });
          } else {
            setState(() {});
          }

          return;
        }
      }

      setState(() {
        text.add('It doesn\'t look like it will be open again this week.');
      });

      return;
    } else {
      print('Dining hall ${favoriteHall.hallName} is not fully closed today (${menuDate.weekday})');
    }

    TimeOfDay timeNow = TimeOfDay.now();
    DiningHallHours relevant = MenuDate.getFirstRelevant(hoursToday, timeNow);

    if (relevant != null) {
      if (relevant.isNow()) {
        setState(() {
          text.add(
            'It\'s currently serving ${relevant.meal.name} '
            'until ${DateUtil.formatTimeOfDay(relevant.endTime)}'
          );
        });
      } else {
        setState(() {
          text.add(
            'It will serve ${relevant.meal.name} '
            'at ${DateUtil.formatTimeOfDay(relevant.beginTime)}'
          );
        });
      }
      return;
    }

    for (int i = 1; i < 7; i++) {
      menuDate.forward();

      List<DiningHallHours> nextHours = menuDate.getDayHours(favoriteHall);
      if (!DiningHallHours.isFullyClosed(nextHours)) {
        DiningHallHours relevant = MenuDate.getFirstRelevant(
            nextHours,
            new TimeOfDay(hour: 0, minute: 0)
        );

        if (relevant != null) {
          setState(() {
            text.add(
              'It will serve ${relevant.meal.name} on '
              '${DateUtil.getWeekday(menuDate.time)} at ${DateUtil.formatTimeOfDay(relevant.beginTime)}'
            );
          });
        } else {
          setState(() {
            text.add('The next opening can\'t be found.');
          });
        }

        return;
      }
    }

    setState(() {
      text.add('The next opening can\'t be found.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MiniWidget(
      icon: Icons.restaurant,
      title: 'Dining Halls',
      subtitle: 'Decent food, but also on combo!',
      text: text,
      bottomBar: widget.homePage.bottomBar,
      index: 1,
      active: !hasFailed && favoriteHall != null
    );
  }
}