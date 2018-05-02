import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';
import 'package:msu_helper/api/dining_hall/provider.dart';
import 'package:msu_helper/api/dining_hall/relevant.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/pages/dining_hall/hall_info_page.dart';
import 'package:msu_helper/util/ListUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';
import '../../api/settings/provider.dart' as settingsProvider;
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

  Widget buildDiningHallButton(DiningHall diningHall) {
    return new InkWell(
      child: new Container(
        decoration: new BoxDecoration(
            color: Colors.lightGreen[200],
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              offset: const Offset(0.0, 1.0),
              blurRadius: 4.0
            )
          ]
        ),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: new Column(
          children: ListUtil.add(
              [new Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: new Center(
                    child: new Text(diningHall.hallName,
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500
                        )
                    )),
              )],
              getSuperRelevantLines(diningHall).map((s) => new Center(child: new Text(s))).toList()
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new HallInfoPage(diningHall))
        );
      },
    );
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

    List<Widget> children = <Widget>[
      new Container(
        padding: const EdgeInsets.all(12.0),
        child: new Center(child: new Text('Tap a dining hall to view its menu/hours!')),
      ),
    ];

    if (favoriteHall != null) {
      children.add(new Column(
        children: <Widget>[
          new Divider(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(6.0),
                child: new Icon(Icons.star, color: Colors.yellow),
              ),
              new Text('Favorite Hall')
            ],
          ),
          buildDiningHallButton(favoriteHall),
          new Divider()
        ],
      ));
    }

    children.add(new Expanded(
        child: new GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          children: diningHalls.map(buildDiningHallButton).toList(),
        )
    ));

    return new Column(
      children: children,
    );
  }
}