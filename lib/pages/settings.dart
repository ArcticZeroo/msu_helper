import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/config/Identifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/TextUtil.dart';

class SettingsPage extends StatefulWidget {
  createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController textController = new TextEditingController();

  String savedName = 'loading...';
  TextField textField;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance()
        .then((SharedPreferences preferences) {

          savedName = preferences.getString(Identifiers.USER_NAME_STORAGE);

          setState(() {});
        })
        .catchError((e) {
          print('Could not retrieve username: $e');
        });

    textField = new TextField(
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
          hintText: 'Your name',
          hintStyle: new TextStyle(
              color: Colors.black54,
              fontSize: 16.0
          )
      ),
      controller: textController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(color: Colors.white),
        title: TextUtil.getAppBarTitle('Settings'),
      ),
      body: new ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.person),
            title: new Text('Your name'),
            subtitle: new Text('Your name is currently ${savedName ?? 'not set'}.'),
            onTap: () {
              showDialog(context: context, child: new AlertDialog(
                title: new Text('Enter your name'),
                content: textField,
                actions: <Widget>[
                  new FlatButton(
                      child: new Text('CANCEL'),
                      onPressed: () { Navigator.maybePop(context); },
                      textColor: Theme.of(context).primaryColor
                  ),
                  new FlatButton(
                      child: new Text('OK'),
                      onPressed: () async {
                        SharedPreferences preferences = await SharedPreferences.getInstance();

                        savedName = textController.text;
                        preferences.setString(Identifiers.USER_NAME_STORAGE, textController.text);

                        await Navigator.maybePop(context);

                        setState(() {});
                      },
                      textColor: Theme.of(context).primaryColor
                  )
                ],
              ));
            },
          )
        ],
      ),
    );
  }
}