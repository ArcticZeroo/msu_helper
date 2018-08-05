import 'dart:math';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/movie_night/structures/movie_showing.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/collapsible/collapsible_card.dart';
import 'package:msu_helper/widgets/collapsible/collapsible_custom.dart';
import 'package:msu_helper/widgets/material_card.dart';

class MovieDisplay extends StatefulWidget {
  final Movie movie;

  MovieDisplay(this.movie);

  @override
  State<StatefulWidget> createState() => new MovieDisplayState();
}

class MovieDisplayState extends State<MovieDisplay> {
  static const Radius borderRadius = const Radius.circular(4.0);
  final Widget mediumSpacer = new Container(height: 8.0);
  final Widget smallSpacer = new Container(height: 4.0);
  final int timesPerRow = 2;

  bool collapsed = false;

  Widget buildBody() {
    List<Widget> children = [];

    for (String location in widget.movie.groupedShowings.keys) {
      List<DateTime> showings = widget.movie.groupedShowings[location];

      Map<String, List<DateTime>> showingsByWeekday = {};

      for (DateTime showing in showings) {
        String weekday = DateUtil.getWeekday(showing);

        if (!showingsByWeekday.containsKey(weekday)) {
          showingsByWeekday[weekday] = [];
        }

        showingsByWeekday[weekday].add(showing);
      }

      List<String> sortedWeekdays = showingsByWeekday.keys.toList();
      sortedWeekdays.sort((a, b) => DateUtil.getWeekdayValue(a) - DateUtil.getWeekdayValue(b));

      List<Widget> locationChildren = [];

      for (String weekday in sortedWeekdays) {
        List<DateTime> showingsForWeekday = showingsByWeekday[weekday];
        showingsForWeekday.sort((a, b) => a.compareTo(b));

        locationChildren.add(new Text(
            '${DateUtil.formatDateFully(showingsForWeekday.first)}: ${showingsForWeekday.map(DateUtil.toTimeString).join(', ')}',
            style: MaterialCard.subtitleStyle.copyWith(color: Colors.grey[200])
        ));
      }

      children.add(new Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(location, style: new TextStyle(fontSize: 16.0, color: Colors.white)),
            new Container(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: locationChildren,
              ),
            )
          ],
        ),
      ));
    }

    return new Column(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  /**
   * new CollapsibleCard(
      backgroundColor: Colors.green[700],
      arrowColor: Colors.white,
      title: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      new Icon(Icons.movie, color: Colors.grey[200]),
      new Container(width: 12.0),
      new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      new Text(widget.movie.title,
      style: MaterialCard.titleStyle.copyWith(color: Colors.white)),
      new Text('${widget.movie.showings.length} showing${widget.movie.showings.length == 1 ? '' : 's'} listed',
      style: MaterialCard.subtitleStyle.copyWith(color: Colors.grey[300]))
      ],
      )
      ],
      ),
      body: buildBody()
      )
   */

  BoxDecoration getRoundedBox(Color color, [BorderRadius boxBorderRadius]) {
    return new BoxDecoration(
        color: color,
        borderRadius: boxBorderRadius
    );
  }

  Widget buildMiniCard(Color color, Widget child, {BorderRadius cardBorderRadius = const BorderRadius.all(borderRadius), double width}) {
    return new Container(
        padding: const EdgeInsets.all(8.0),
        decoration: getRoundedBox(color, cardBorderRadius),
        child: child,
        width: width
    );
  }

  Widget buildNumberIndicator(int count, [Color textColor]) {
    return new CircleAvatar(
      maxRadius: 12.0,
      backgroundColor: Colors.white,
      child: new Text(count.toString(),
          style: new TextStyle(color: textColor, fontWeight: FontWeight.w800)),
    );
  }

  Widget buildTitleCard() {
    return buildMiniCard(
        Colors.green[700],
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Icon(Icons.movie, color: Colors.white),
            new Text(widget.movie.title,
                textAlign: TextAlign.center,
                style: MaterialCard.titleStyle.copyWith(color: Colors.white)),
            buildNumberIndicator(widget.movie.showings.length)
          ],
        ),
        cardBorderRadius: const BorderRadius.only(
            topLeft: borderRadius,
            topRight: borderRadius
        )
    );
  }

  Widget buildLocationCard(String location, int showings) {
    return buildMiniCard(
        Colors.green,
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Icon(Icons.location_on, color: Colors.white),
            new Text(location,
                textAlign: TextAlign.center,
                style: MaterialCard.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: MaterialCard.titleStyle.fontSize - 4.0)
            ),
            buildNumberIndicator(showings)
          ],
        ),
        cardBorderRadius: const BorderRadius.only()
    );
  }

  Widget buildDayCard(List<DateTime> days) {
    DateTime day = days.first;

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        smallSpacer,
        buildMiniCard(
            Colors.green[200],
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Icon(Icons.date_range),
                new Text(DateUtil.formatDateFully(day),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
                buildNumberIndicator(days.length)
              ],
            )
        )
      ],
    );
  }

  Widget buildTimeCard(DateTime time) {
    return new Chip(label: new Text(DateUtil.toTimeString(time)));
  }

  Widget buildWeekdayRow(List<DateTime> dates) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
              DateUtil.formatDateFully(dates.first),
              style: new TextStyle(fontWeight: FontWeight.w700)
          ),
          new Text(dates.map(DateUtil.toTimeString).join(', '))
        ]
    );
  }

  Widget buildLocationShowingsCard(String location, List<DateTime> showings) {
    var groupedShowings = DateUtil.groupByWeekday(showings);

    List<Widget> weekdayChildren = groupedShowings.values
        .map(buildWeekdayRow)
        .toList(growable: false);

    return new CollapsibleCustom(
      title: buildLocationCard(location, showings.length),
      body: buildMiniCard(
          Colors.green[200],
          new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: weekdayChildren,
          ),
          cardBorderRadius: const BorderRadius.only(
              bottomLeft: borderRadius,
              bottomRight: borderRadius
          )
      ),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch
    );
  }



  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[buildTitleCard()];

    for (var entry in widget.movie.groupedShowings.entries) {
      columnChildren.add(buildLocationShowingsCard(entry.key, entry.value));
    }

    return new Container(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
        children: columnChildren.toList(),
      ),
    );
  }
}