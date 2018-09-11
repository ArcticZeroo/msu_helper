import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/movie_night/provider.dart' as movieProvider;
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/movie_night/movie_display.dart';

class MovieNightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MovieNightPageState();
}

class MovieNightPageState extends State<MovieNightPage> {
  Future<List<Movie>> _movieLoader;

  @override
  void initState() {
    super.initState();

    _movieLoader = movieProvider.retrieveMovies();
  }

  Widget buildMovie(Movie movie) {
    return new MovieDisplay(movie);
  }

  Widget buildPageDisplay(List<Movie> movies) {
    List<Widget> columnChildren = [];

    if (movies.length == 0) {
      columnChildren.addAll([
        new Center(child: new Text('No movies are posted.', style: MaterialCard.titleStyle)),
        new Center(child: new Text('Check back later?', style: MaterialCard.subtitleStyle)),
      ]);
    }

    DateTime now = DateTime.now();
    List<Movie> moviesNotPassed = movies.where(
            (movie) => movie.showings.firstWhere(
                (showing) => showing.date.isAfter(now),
            orElse: () => null
        ) != null).toList();

    DateTime latestShowing = Movie.findLatestShowing(movies)?.date;

    bool hasBeenAtLeastOneWeek = (latestShowing == null) || DateTime.now().difference(latestShowing).inDays >= 7;

    String title;
    if (moviesNotPassed.length == 0 && (Movie.NOT_YET_POSTED_DAYS.contains(now.weekday) || hasBeenAtLeastOneWeek)) {
      if (hasBeenAtLeastOneWeek) {
        title = "Old Listed Movies";
      } else {
        title = "Last Week's Movies";
      }
    } else {
      title = "This Week's Movies";
    }

    columnChildren.add(new Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: new Center(child: new Text(title, style: MaterialCard.titleStyle))
    ));
    columnChildren.addAll(movies.map(buildMovie));

    return new Center(
      child: new Scrollbar(
          child: new RefreshIndicator(
              child: new ListView(
                scrollDirection: Axis.vertical,
                children: columnChildren,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () async {
                // Only set the movie loader if it completed successfully,
                // because we don't actually want to kill the existing movies
                // page if loading failed
                try {
                  Future loader = movieProvider.retrieveMoviesFromWebAndSave();
                  await loader;
                  setState(() {
                    _movieLoader = loader;
                  });
                } catch (e) {
                  print('Could not refresh movies from web:');
                  print(e);
                }
              })
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _movieLoader,
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              return new Center(
                  child: new ErrorCardWidget('Unable to load movies')
              );
            }

            var data = snapshot.data as List<Movie>;

            return buildPageDisplay(data);
          default:
            return new Center(
              child: new Row(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(8.0),
                    child: new CircularProgressIndicator(),
                  ),
                  new Text('Loading movies...')
                ],
              ),
            );
        }
      },
    );
  }
}