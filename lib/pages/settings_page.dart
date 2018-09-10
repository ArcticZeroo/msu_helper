import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/settings/favorite_dining_hall.dart';
import 'package:msu_helper/widgets/settings/boolean_setting.dart';

class SettingsPage extends StatefulWidget {
  static const String reloadableCategory = 'settings_dependent';

  @override
  State<StatefulWidget> createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Widget buildTitle(String text) {
    return new Container(
      padding: const EdgeInsets.all(4.0),
      child: new Center(
        child: new Text(text),
      ),
    );
  }

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
            buildTitle('Home Page'),
            new ListTile(
              leading: new Icon(Icons.restaurant),
              title: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(SettingsConfig.favoriteDiningHall.title),
                  new Text(SettingsConfig.favoriteDiningHall.description, style: MaterialCard.subtitleStyle)
                ],
              ),
              subtitle: new FavoriteDiningHall(),
            ),
            new Divider(color: Colors.black38,),
            // DINING HALL SETTINGS
            buildTitle('Dining Halls'),
            new BooleanSettingWidget(SettingsConfig.showVenueDescriptions, new Icon(Icons.edit)),
            new BooleanSettingWidget(SettingsConfig.collapseVenuesByDefault, new Icon(Icons.remove_red_eye)),
            new BooleanSettingWidget(SettingsConfig.showHallHours, new Icon(Icons.timer)),
            new BooleanSettingWidget(SettingsConfig.intelligentVenueOrdering, new Icon(Icons.lightbulb_outline)),
            // DINING HALL SETTINGS END
            new Divider(color: Colors.black38),
            // EXPERIMENTAL SETTINGS
            new Center(child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(Icons.warning, color: Colors.deepOrange),
                buildTitle('Experimental')
              ])
            ),
            new ListTile(
                leading: new Icon(Icons.refresh),
                title: new Text('Refresh Data'),
                subtitle: new Text('Something gone wrong? Tap here to return to the preloading page to reload data.'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
            ),
            new BooleanSettingWidget(SettingsConfig.skipPreloadAutomatically, new Icon(Icons.fast_forward)),
            // EXPERIMENTAL SETTINGS END
          ],
        ),
      )
    );
  }
}