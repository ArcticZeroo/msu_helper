import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/setting_data.dart';

import '../../api/settings/provider.dart' as settingsProvider;

class BooleanSettingWidget extends StatelessWidget {
  final SettingData data;
  final Icon icon;
  final bool isCheckbox;

  BooleanSettingWidget(this.data, this.icon, [this.isCheckbox = false]);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: icon,
      title: new Text(data.title),
      subtitle: data.description == null ? null : new Text(data.description),
      trailing: new BooleanSettingSwitch(data, isCheckbox),
    );
  }
}

class BooleanSettingSwitch extends StatefulWidget {
  final SettingData data;
  final bool isCheckbox;

  BooleanSettingSwitch(this.data, this.isCheckbox);

  @override
  State<StatefulWidget> createState() => new _SwitchState();
}

class _SwitchState extends State<BooleanSettingSwitch> {
  bool value;

  @override
  void initState() {
    super.initState();

    value = settingsProvider.getCached(widget.data);
  }

  void onValueChanged(bool newValue) {
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

  @override
  Widget build(BuildContext context) {
    return widget.isCheckbox ? new Checkbox(value: value, onChanged: onValueChanged) : new Switch(value: value, onChanged: onValueChanged);
  }
}