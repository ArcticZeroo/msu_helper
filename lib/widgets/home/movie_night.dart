import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/movie_night/provider.dart' as movieNightProvider;
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/widgets/home/mini_widget.dart';

class MovieNightMiniWidget extends StatefulWidget {
  final HomePage homePage;

  MovieNightMiniWidget(this.homePage);

  @override
  State<StatefulWidget> createState() => new MovieNightMiniWidgetState();
}

class MovieNightMiniWidgetState extends Reloadable<MovieNightMiniWidget> {
  List<String> text = ['Loading...'];
  bool hasFailed = false;

  MovieNightMiniWidgetState() : super([HomePage.reloadableCategory]) {
    loadWithoutAsync();
  }

  loadWithoutAsync() {
    load().catchError((e) {
      print('Could not load movie night data:');
      print(e.toString());
      print((e as Error).stackTrace);

      setState(() {
        text = ['Unable to load movie night information.'];
        hasFailed = true;
      });
    });
  }

  Future load() async {
    List<Movie> movies = await movieNightProvider.retrieveMovies();

    hasFailed = false;

    DateTime now = DateTime.now();
    List<Movie> moviesNotPassed = movies.where(
            (movie) => movie.showings.firstWhere(
                (showing) => showing.date.isAfter(now),
                orElse: () => null
            ) != null).toList();

    if (moviesNotPassed.isEmpty) {
      if (Movie.NOT_YET_POSTED_DAYS.contains(now.weekday)) {
        setState(() {
          text = ['Movie showtimes haven\'t been posted for this week.'];
        });
      } else {
        setState(() {
          text = ['All movie showtimes for this week have passed.'];
        });
      }

      return;
    }

    setState(() {
      text = ['Movies this week: ${movies.map((movie) => movie.title).join(', ')}'];
    });
  }

  @override
  void reload(Map<String, dynamic> params) {
    if (params.containsKey('refresh')) {
      setState(() {
        text = ['Loading...'];
      });

      movieNightProvider.retrieveMoviesFromWebAndSave()
        .then((v) => load())
        .catchError((e) {
            print(e);

            setState(() {
              text = ['Could not refresh movie data.'];
              hasFailed = true;
            });
        });
    } else {
      super.reload(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MiniWidget(
        icon: Icons.movie,
        title: 'Movie Night',
        subtitle: 'There\'s usually something good. But it\'s free!',
        text: text,
        bottomBar: widget.homePage.bottomBar,
        index: 3,
        active: !hasFailed
    );
  }
}