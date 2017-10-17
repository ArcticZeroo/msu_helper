import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/movies.dart';

Widget getMovieTimesPage(Movie movie) {
  List<Widget> widgets = new List();

  for (MovieShowing showing in movie.showings) {
    widgets.add(new ListTile(
        leading: new Icon(Icons.local_movies),
        title: new Text('${showing.location} on ${new DateFormat('EE MMMM d, hh:mm aaa').format(showing.time)}')
    ));
  }

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