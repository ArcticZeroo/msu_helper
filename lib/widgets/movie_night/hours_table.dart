import 'dart:math';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/movie_night/structures/movie_showing.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/ListUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';

class HoursTable extends StatefulWidget {
  final Movie movie;

  const HoursTable(this.movie);

  @override
  State<StatefulWidget> createState() => new HoursTableState();
}

class HoursTableState extends State<HoursTable> {
  bool collapsed = false;
  Widget _table;

  Widget buildTable() {
    if (_table != null) {
      return _table;
    }

    Set<int> showtimeDaysSet = new Set();

    for (MovieShowing showing in widget.movie.showings) {
      showtimeDaysSet.add(showing.date.weekday);
    }

    List<int> showtimeDaysList = List.from(showtimeDaysSet);
    showtimeDaysList.sort((a, b) => a.compareTo(b));

    List<String> header = [''];
    //header.addAll(showtimeDaysList.map((dayInt) => DateUtil.getWeekday(from)))

    List<TableRow> rows = <TableRow>[];

    _table = new Table(children: rows);
    return _table;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialCard(
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('${widget.movie.title} Showtimes', style: MaterialCard.titleStyle),
          new IconButton(
            tooltip: collapsed ? 'Show Showtimes' : 'Hide Showtimes',
            icon: new Icon(collapsed ? Icons.add : Icons.remove),
            onPressed: () {
              setState(() {
                collapsed = !collapsed;
              });
          })
        ],
      ),
      body: collapsed ? null : buildTable()
    );
  }
}