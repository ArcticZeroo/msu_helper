import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';

class MiniWidgetDisplay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> text;

  MiniWidgetDisplay({
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
              color: Colors.grey[700]
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

  MiniWidget({
    @required
    this.icon,
    @required
    this.title,
    @required
    this.subtitle,
    @required
    this.index,
    @required
    this.bottomBar,
    @required
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: () {
        bottomBar.setPage(index);
      },
      child: new MiniWidgetDisplay(
          icon: icon,
          title: title,
          subtitle: subtitle,
          text: text
      ),
    );
  }
}