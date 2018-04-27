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
    List<Widget> columnChildren = <Widget>[
      new Container(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: new Text(
          title,
          style: new TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

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
          style: new TextStyle(color: Colors.grey[800]),
        ));
      }
    }

    return new Row(
      children: <Widget>[
        icon,
        new Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnChildren
          ),
        )
      ],
    );
  }
}