import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';

class MiniWidgetDisplay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> text;
  final bool active;

  MiniWidgetDisplay({
    @required this.icon,
    @required this.title,
    @required this.active,
    this.subtitle,
    this.text,
  });

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
          style: new TextStyle(color: Colors.grey[700]),
        ));
      }
    }

    return new Center(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(32.0),
            child: new Icon(
                icon,
                color: active
                    ? Theme.of(context).primaryColor
                    : Colors.grey[500]
            ),
          ),
          new Expanded(
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columnChildren
            ),
          )
        ],
      ),
    );
  }
}

class MiniWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;
  final MainBottomBar bottomBar;
  final List<String> text;
  final bool active;

  MiniWidget({
    @required this.icon,
    @required this.title,
    @required this.subtitle,
    @required this.index,
    @required this.bottomBar,
    @required this.text,
    this.active = false
  });

  @override
  Widget build(BuildContext context) {
    MiniWidgetDisplay display = new MiniWidgetDisplay(
      icon: icon,
      title: title,
      subtitle: subtitle,
      text: text,
      active: active,
    );

    if (active) {
      return new InkWell(
        onTap: () {
          bottomBar.setPage(index);
        },
        child: display,
      );
    }

    return display;
  }
}