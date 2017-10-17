import 'dart:async';

import 'package:msu_helper/config/Pages.dart';

import './request.dart';

class MovieShowing {
  final String location;
  final DateTime time;

  MovieShowing.fromJson(Map<String, dynamic> jsonObject) :
    this.location = jsonObject['location'],
    this.time = new DateTime.fromMillisecondsSinceEpoch(jsonObject['time']);
}

class Movie {
  final String title;
  final List<MovieShowing> showings;

  Movie(this.title, this.showings);
}

class MovieNightResponse {
  static List<Movie> cached;

  static Future<List<Movie>> get([bool refresh = false]) async {
    if (!refresh && MovieNightResponse.cached != null) {
      return cached;
    }

    Map<String, dynamic> jsonObject = await makeRestRequest(Pages.getUrl(Pages.MOVIE_NIGHT));

    List<Map<String, dynamic>> movieObjects = jsonObject['movies'];

    List<Movie> movies = new List();

    for (Map<String, dynamic> movieObject in movieObjects) {
      List<MovieShowing> showings = new List();

      for (Map<String, dynamic> showingObject in movieObject['showings']) {
        showings.add(new MovieShowing.fromJson(showingObject));
      }

      movies.add(new Movie(movieObject['title'], showings));
    }

    cached = movies;

    return movies;
  }
}