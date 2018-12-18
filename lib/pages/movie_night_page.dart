import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/movie_night/provider.dart' as movieProvider;
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/loading_widget.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/movie_night/movie_display.dart';
import 'package:msu_helper/widgets/movie_night/movie_list_title.dart';

class MovieNightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MovieNightPageState();
}

class MovieNightPageState extends State<MovieNightPage> {
  Future<List<Movie>> _movieLoader;
  Widget _movieDisplays;

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

    if (movies.isEmpty) {
      columnChildren.add(new MaterialCard(
          title: new Text('No movies are posted.'),
          subtitle: new Text('Check back later?')));
    }

    DateTime now = DateTime.now();
    List<Movie> moviesNotPassed = movies
        .where((movie) =>
            movie.showings.firstWhere((showing) => showing.date.isAfter(now),
                orElse: () => null) !=
            null)
        .toList();

    DateTime latestShowing = Movie.findLatestShowing(movies)?.date;

    // We check for latestShowing == null because if there is no latest showing I guess
    // we just assume they haven't been posted in a long time
    bool hasBeenAtLeastOneWeek = (latestShowing == null) ||
        DateTime.now().difference(latestShowing).inDays >= 7;

    String title;
    if (moviesNotPassed.length == 0 &&
        (Movie.NOT_YET_POSTED_DAYS.contains(now.weekday) ||
            hasBeenAtLeastOneWeek)) {
      if (hasBeenAtLeastOneWeek) {
        title = "Old Listed Movies";
      } else {
        title = "Last Week's Movies";
      }
    } else {
      title = "This Week's Movies";
    }

    columnChildren.add(MovieListTitle(title));
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
              })),
    );
  }

  @override
  Widget build(BuildContext context) => new FutureBuilder(
      future: _movieLoader,
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (_movieDisplays == null) {
              var data = snapshot.data as List<Movie>;

              _movieDisplays = buildPageDisplay(data);
            } else if (snapshot.hasError) {
              return new Center(
                  child: new ErrorCardWidget('Unable to load movies'));
            }

            return _movieDisplays;
          default:
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new LoadingWidget(name: 'movies')
              ],
            );
        }
      },
    );
}
