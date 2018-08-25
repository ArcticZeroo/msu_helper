import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';
import 'package:msu_helper/api/dining_hall/relevant.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/config/settings_config.dart';
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

    // Reloads when the favorite dining hall is set
    addSettingListener(SettingsConfig.favoriteDiningHall, (String last) {
      load();
    });
  }

  Future _retrieveDataAndUpdate() async {
    favoriteHall = await retrieveFavoriteHall();

    if (!mounted) {
      return;
    }

    if (favoriteHall == null) {
      setState(() {
        text = ['You don\'t have a favorite hall set! Add one in the settings.'];
      });
      return;
    }

    text = ['Your favorite: ${favoriteHall.hallName}'];

    setState(() {
      text.addAll(getSuperRelevantLines(favoriteHall));
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
      index: 2,
      active: !hasFailed
    );
  }
}