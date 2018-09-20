import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/setting_data.dart';

import '../../api/settings/provider.dart' as settingsProvider;

class BooleanSettingWidget extends StatelessWidget {
  final SettingData data;
  final Icon icon;

  BooleanSettingWidget(this.data, this.icon);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: icon,
      title: new Text(data.title),
      subtitle: new Text(data.description),
      trailing: new BooleanSettingSwitch(data),
    );
  }
}

class BooleanSettingSwitch extends StatefulWidget {
  final SettingData data;

  BooleanSettingSwitch(this.data);

  @override
  State<StatefulWidget> createState() => new _VenueDescriptions();
}

class _VenueDescriptions extends State<BooleanSettingSwitch> {
  bool value;

  @override
  void initState() {
    super.initState();

    value = settingsProvider.getCached(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return new Switch(
        value: value,
        onChanged: (bool newValue) {
          widget.data.save(newValue)
          .then((_) {
            print('Saved setting for key ${widget.data.key}');
          })
          .catchError((error) {
            print('Could not save setting ${widget.data.key}');
            print(error);

            if (error is Error) {
              print(error.stackTrace);
            }
          });

          setState(() {
            value = newValue;
          });
        }
    );
  }
}