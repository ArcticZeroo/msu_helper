import 'dart:async';

import 'package:msu_helper/config/Pages.dart';

import './request.dart';

class MovieShowing {
  final String location;
  final DateTime time;

  MovieShowing.fromJson(Map<String, dynamic> jsonObject) :
    this.location = jsonObject['location'],
    this.time = new DateTime.fromMillisecondsSinceEpoch(jsonObject['date']);
}

class Movie {
  final String title;
  final List<MovieShowing> showings;
  final List<String> showingLocations;
  final Map<String, List<DateTime>> groupedShowings;

  Movie({this.title, this.showings, this.showingLocations, this.groupedShowings});
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

      Map<String, List<num>> groupedShowingObjects = movieObject['groupedShowings'];
      Map<String, List<DateTime>> groupedShowings = new Map();

      groupedShowingObjects.forEach((String location, List<num> showingNums) {
        List<DateTime> showingDates = showingNums.map((n) => new DateTime.fromMillisecondsSinceEpoch(n));

        groupedShowings[location] = showingDates;
      });

      movies.add(new Movie(title: movieObject['title'], showings: showings, showingLocations: movieObject['locations'], groupedShowings: groupedShowings));
    }

    cached = movies;

    return movies;
  }
}