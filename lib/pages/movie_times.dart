import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/movies.dart';
import 'package:msu_helper/util/UrlUtil.dart';

final DateFormat timeFormat = new DateFormat('EEEE MMMM d, hh:mm aaa');

Widget getMovieTimesPage(Movie movie) {
  List<Widget> widgets = new List();

  movie.groupedShowings.forEach((String location, List<DateTime> times) {
    Text title = new Text(location);

    int nextShowing = Movie.getNextShowing(times);

    List<Widget> locationWidgets = <Widget>[
      new ListTile(leading: new Icon(nextShowing == -1 ? Icons.mood_bad : Icons.location_on), title: title, subtitle: (nextShowing == -1) ? new Text('All of the below showtimes have passed for this location.') : new Text(''), onTap: () { UrlUtil.openMapsToLocation(location); })
    ];

    for (DateTime time in times) {
      locationWidgets.add(new Text(timeFormat.format(time), textAlign: TextAlign.left, style: new TextStyle(
        color: Colors.black54
      )));
    }

    widgets.add(new Column(
      children: locationWidgets,
    ));
  });

  return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text('${movie.title} Showtimes'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(16.0),
          child: new Column(
              children: widgets
          )
      )
  );
}