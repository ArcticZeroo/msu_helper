import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';

import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings.dart';
import 'package:msu_helper/pages/main_page.dart';

class FavoriteDiningHall extends StatefulWidget {
  FavoriteDiningHall();

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
    diningHalls = await diningHallProvider.retrieveList();

    print('Got dining halls');
    print('There are ${diningHalls.length}');

    DiningHall favoriteHall = await retrieveFavoriteHall();

    setState(() {
      selected = favoriteHall;
    });
  }

  List<DropdownMenuItem<DiningHall>> buildItems() {
    return diningHalls.map((diningHall) => new DropdownMenuItem(
      value: diningHall,
      child: new Text(diningHall.hallName)
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      print('Dining hall loading failed');
      return new Text('Unable to load dining halls.');
    }

    if (diningHalls == null || diningHalls.length == 0) {
      print('Dining halls have not yet loaded');
      return new Text('Loading dining halls...');
    }

    print('Loading a dropdown');

    return new DropdownButton<DiningHall>(
      items: buildItems(),
      value: selected,
      hint: new Text('Dining Hall Selection'),
      onChanged: (DiningHall value) {
        setState(() {
          selected = value;
        });

        print('Saving favorite dining hall to ${value.searchName}');
        _settingData.save(value.searchName)
            .then((v) {
              print('Saved!');
              MainPage.mainPageState.currentState?.rebuild();
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