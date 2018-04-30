import 'dart:async';

import 'package:flutter/material.dart';

class DiningMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new DiningMainPageState();
}

class DiningMainPageState extends State<DiningMainPage> {
  DateTime _selectedTime;

  DateTime get selectedTime => _selectedTime;

  Future<DateTime> selectTime(BuildContext context) async {
    final DateTime dateTime = await showDatePicker(
        context: context,
        initialDate: _selectedTime ?? DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(Duration(days: 7))
    );

    if (dateTime == null) {
      return _selectedTime;
    }

    _selectedTime = dateTime;

    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[

      ],
    );
  }
}