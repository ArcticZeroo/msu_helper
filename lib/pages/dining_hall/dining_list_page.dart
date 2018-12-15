import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';
import 'package:msu_helper/api/dining_hall/provider.dart';
import 'package:msu_helper/api/dining_hall/relevant.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/pages/dining_hall/menu_page.dart';
import 'package:msu_helper/util/ListUtil.dart';
import 'package:msu_helper/widgets/dining_hall/list_item.dart';
import 'package:msu_helper/widgets/loading_widget.dart';

import '../../config/settings_config.dart';

class DiningMainPage extends StatefulWidget {
  static const String reloadableCategory = 'dining_info';

  @override
  State<StatefulWidget> createState() => new DiningMainPageState();
}

class DiningMainPageState extends Reloadable<DiningMainPage> {
  List<DiningHall> diningHalls;
  DiningHall favoriteHall;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    load();

    addSettingListener(SettingsConfig.favoriteDiningHall, (String last) {
      load();
    });
  }

  Future load() async {
    try {
      diningHalls = await retrieveDiningList();
      favoriteHall = await retrieveFavoriteHall();
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
      return Center(
        child: Text('Could not load dining hall information.'),
      );
    }

    if (diningHalls == null) {
      return LoadingWidget(
        name: 'Dining Halls'
      );
    }

    List<Widget> children = <Widget>[
      Container(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Text('Tap a dining hall to view its menu/hours!')
        ),
      ),
    ];

    if (favoriteHall != null) {
      children.add(FavoriteDiningHallListItem(favoriteHall));
    }

    children.add(Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          children: diningHalls
            .map((hall) => DiningHallListItem(hall))
            .toList(),
        )
    ));

    return Column(
      children: children,
    );
  }
}