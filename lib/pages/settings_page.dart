import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/settings/favorite_dining_hall.dart';
import 'package:msu_helper/widgets/settings/boolean_setting.dart';

class SettingsPage extends StatefulWidget {
  static const String reloadableCategory = 'settings_dependent';

  @override
  State<StatefulWidget> createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new ListView(
          children: <Widget>[
            new Center(child: new Text('Home Page')),
            new ListTile(
              leading: new Icon(Icons.restaurant),
              title: new Text(SettingsConfig.favoriteDiningHall.title),
              subtitle: new Text(SettingsConfig.favoriteDiningHall.description),
              trailing: new FavoriteDiningHall(),
            ),
            new Divider(color: Colors.black38,),
            new Center(child: new Text('Dining Halls')),
            new BooleanSettingWidget(SettingsConfig.showVenueDescriptions, new Icon(Icons.edit)),
            new BooleanSettingWidget(SettingsConfig.collapseVenuesByDefault, new Icon(Icons.remove_red_eye)),
            new BooleanSettingWidget(SettingsConfig.showHallHours, new Icon(Icons.timer)),
            new BooleanSettingWidget(SettingsConfig.intelligentVenueOrdering, new Icon(Icons.lightbulb_outline))
          ],
        ),
      )
    );
  }
}