import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/controller.dart';

import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/pages/main_page.dart';
import 'package:msu_helper/pages/settings_page.dart';
import '../../api/settings/provider.dart' as settingsProvider;

class VenueDescriptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _VenueDescriptions();
}

class _VenueDescriptions extends State<VenueDescriptions> {
  static final SettingData _settingData = SettingsConfig.showVenueDescriptions;
  bool value = settingsProvider.getCached(_settingData);

  @override
  Widget build(BuildContext context) {
    return new Switch(
        value: value,
        onChanged: (bool newValue) {
          _settingData.save(newValue);

          setState(() {
            value = newValue;
          });
        }
    );
  }
}