import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MiniWidget extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subtitle;
  final List<String> text;

  MiniWidget({
    @required
    this.icon,
    @required
    this.title,
    this.subtitle,
    this.text});

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[];

    if (subtitle != null) {
      columnChildren.add(new Container(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: new Text(
          subtitle,
          style: new TextStyle(color: Colors.grey[500]),
        ),
      ));
    }

    if (text != null) {
      for (String line in text) {
        columnChildren.add(new Text(
          line,
          style: new TextStyle(color: Colors.grey[600]),
        ));
      }
    }

    return new Center(
      child: new ListTile(
        leading: icon,
        title: new Text(title),
        subtitle: new Column(
          children: columnChildren,
        ),
      ),
    );
  }
}