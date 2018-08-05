import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/collapsible/animation/child_collapser.dart';

class MovieLocationDisplay extends StatefulWidget {
  final String location;
  final List<DateTime> showings;

  MovieLocationDisplay({this.location, this.showings});

  @override
  State<StatefulWidget> createState() => new _MovieLocationDisplayState();
}

class _MovieLocationDisplayState extends State<MovieLocationDisplay> {
  @override
  Widget build(BuildContext context) {
    return new ChildCollapser(
      child: new Container()
    );
  }
}