import 'package:flutter/material.dart';
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
  final EdgeInsets cardPadding;
  final EdgeInsets bodyPadding;

  MaterialCard({
    this.title,
    this.subtitle,
    this.actions,
    this.body,
    this.onTap,
    this.backgroundColor,
    this.cardPadding = const EdgeInsets.symmetric(vertical: 24.0),
    this.bodyPadding = const EdgeInsets.only(left: 16.0, right:16.0)
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[];

    EdgeInsets headerPadding = const EdgeInsets.only(
        left: 16.0, right: 16.0, bottom: 16.0
    );

    EdgeInsets actionsPadding = const EdgeInsets.all(8.0);

    if (title != null || subtitle != null) {
      columnChildren.add(Container(
        padding: headerPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[title, subtitle].where(ObjectUtil.notNull).toList(),
        ),
      ));
    }

    EdgeInsets desiredBodyPadding = bodyPadding;

    if (actions != null && actions.isNotEmpty) {
      desiredBodyPadding = desiredBodyPadding.copyWith(top: 16.0);

      columnChildren.add(Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: actions.map((action) => Container(
            padding: actionsPadding,
            child: action,
          )).toList(),
        ),
      ));
    }

    if (body != null) {
      columnChildren.add(Container(
        padding: desiredBodyPadding,
        child: body
      ));
    }

    Widget cardChild = Container(
      padding: cardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );

    return Card(
      color: backgroundColor,
      child: InkWell(
          onTap: onTap,
          child: cardChild
      ),
    );
  }
}