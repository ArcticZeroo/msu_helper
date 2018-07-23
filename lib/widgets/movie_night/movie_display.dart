import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/widgets/collapsible_card.dart';
import 'package:msu_helper/widgets/material_card.dart';

class MovieDisplay extends StatefulWidget {
  final Movie movie;

  MovieDisplay(this.movie);

  @override
  State<StatefulWidget> createState() => new MovieDisplayState();
}

class MovieDisplayState extends State<MovieDisplay> {
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
            style: MaterialCard.subtitleStyle
        ));
      }

      children.add(new Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(location, style: new TextStyle(fontSize: 16.0)),
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

  void toggleCollapsed() {
    setState(() {
      collapsed = !collapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(8.0),
      child: new CollapsibleCard(
          backgroundColor: Colors.green[200],
          title: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(widget.movie.title, style: MaterialCard.titleStyle),
              new Text('${widget.movie.showings.length} showing${widget.movie.showings.length == 1 ? '' : 's'} listed')
            ],
          ),
          body: buildBody()
      ),
    );
  }
}