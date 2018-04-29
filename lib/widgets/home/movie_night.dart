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