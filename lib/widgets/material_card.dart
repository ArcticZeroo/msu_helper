import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:msu_helper/util/ObjectUtil.dart';

class MaterialCard extends StatelessWidget {
  static const titleStyle = const TextStyle(
    fontSize: 24.0,
    color: Colors.black87
  );
  static const subtitleStyle = const TextStyle(
    fontSize: 14.0,
    color: Colors.black54
  );
  static const bodyStyle = const TextStyle(
    fontSize: 14.0,
    color: Colors.black87
  );

  final Widget title;
  final Widget subtitle;
  final List<Widget> actions;
  final Widget body;
  final VoidCallback onTap;
  final Color backgroundColor;

  MaterialCard({
    this.title,
    this.subtitle,
    this.actions,
    this.body,
    this.onTap,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[];

    EdgeInsets headerPadding = const EdgeInsets.only(
        left: 16.0, right: 16.0, bottom: 16.0
    );

    EdgeInsets actionsPadding = const EdgeInsets.all(8.0);

    if (title != null || subtitle != null) {
      columnChildren.add(new Container(
        padding: headerPadding,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[title, subtitle].where(ObjectUtil.notNull).toList(),
        ),
      ));
    }

    EdgeInsets bodyPadding = const EdgeInsets.only(
      left: 16.0, right: 16.0
    );

    if (actions != null && actions.length != 0) {
      bodyPadding = bodyPadding.copyWith(top: 16.0);

      columnChildren.add(new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          children: actions.map((action) {
            return new Container(
              padding: actionsPadding,
              child: action,
            );
          }).toList(),
        ),
      ));
    }

    if (body != null) {
      columnChildren.add(new Container(
        padding: bodyPadding,
        child: body,
      ));
    }

    Widget cardChild = new Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );

    return new Card(
      color: backgroundColor,
      child: new InkWell(
          onTap: onTap,
          child: cardChild
      ),
    );
  }
}