import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';

class FavoriteDiningHall extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _FavoriteDiningHallState();
}

class _FavoriteDiningHallState extends State<FavoriteDiningHall> {
  static final SettingData _settingData = SettingsConfig.favoriteDiningHall;

  List<DiningHall> diningHalls;
  DiningHall selected;
  bool failed = false;

  _FavoriteDiningHallState() {
    init().catchError((e) async {
      print('Could not load dining hall settings...');
      print(e.toString());

      if (e is Error) {
        print(e.stackTrace);
      }

      setState(() {
        failed = true;
      });
    });
  }

  Future init() async {
    diningHalls = await diningHallProvider.retrieveDiningList();

    DiningHall favoriteHall = await retrieveFavoriteHall();

    setState(() {
      selected = favoriteHall;
    });
  }

  List<DropdownMenuItem<DiningHall>> buildItems() {
    return diningHalls.map((diningHall) => new DropdownMenuItem(
      value: diningHall,
      child: diningHall.hallName.split(' ').length > 2 ? new Text(diningHall.hallName) : new Text(diningHall.hallName)
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return new Text('Unable to load dining halls.');
    }

    if (diningHalls == null || diningHalls.length == 0) {
      return new Text('Loading dining halls...');
    }

    return new DropdownButton<DiningHall>(
      items: buildItems(),
      value: selected,
      hint: new Text('Select'),
      onChanged: (DiningHall value) {
        setState(() {
          selected = value;
        });

        print('Saving favorite dining hall to ${value.searchName}');
        _settingData.save(value.searchName)
            .then((v) {
              print('Saved!');
            })
            .catchError((e) {
              print('Could not save favorite dining hall...');
              print(e.toString());

              if (e is Error) {
                print(e.stackTrace);
              }

              Scaffold.of(context)
                  .showSnackBar(
                    new SnackBar(
                        content: new Text('Could not save your setting. Try again later?')
                    )
              );
        });
      },
    );
  }
}