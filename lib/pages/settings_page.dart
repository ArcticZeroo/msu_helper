import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/settings/favorite_dining_hall.dart';
import 'package:msu_helper/widgets/settings/venue_descriptions.dart';

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
            new Divider(),
            new Center(child: new Text('Dining Halls')),
            new ListTile(
              leading: new Icon(Icons.edit),
              title: new Text(SettingsConfig.showVenueDescriptions.title),
              subtitle: new Text(SettingsConfig.showVenueDescriptions.description),
              trailing: new VenueDescriptions(),
            ),
          ],
        ),
      )
    );
  }
}