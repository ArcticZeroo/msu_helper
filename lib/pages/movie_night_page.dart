import 'package:flutter/material.dart';
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/movie_night/provider.dart' as movieProvider;
import 'package:msu_helper/widgets/material_card.dart';

class MovieNightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MovieNightPageState();
}

class MovieNightPageState extends State<MovieNightPage> {
  List<Movie> _movies;
  bool failed = false;

  @override
  void initState() {
    super.initState();

    load();
  }

  load() async {
    try {
      _movies = (await movieProvider.retrieveMovies()) ?? [];
    } catch (e) {
      print('Could not load movies:');
      print(e);
      setState(() {
        failed = true;
      });
      return;
    }

    setState(() {
      failed = false;
    });
  }

  Widget buildMovie(Movie movie) {
    List<Widget> lines = [];



    return new Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
        child: new MaterialCard(
          title: new Text(movie.title, style: MaterialCard.titleStyle),
          subtitle: new Text('${movie.showings.length} showing${movie.showings.length == 1 ? '' : 's'} this week'),
          body: new Column(
            children: lines,
          ),
          onTap: null,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return new Center(child: new Text('Unable to load movies.', style: MaterialCard.subtitleStyle));
    }

    if (_movies == null) {
      return new Center(child: new Text('Loading...', style: MaterialCard.subtitleStyle));
    }

    List<Widget> columnChildren = [];

    if (_movies.length == 0) {
      columnChildren.addAll([
        new Center(child: new Text('No movies are posted.', style: MaterialCard.titleStyle)),
        new Center(child: new Text('Check back later?', style: MaterialCard.subtitleStyle)),
      ]);
    }

    DateTime now = DateTime.now();
    List<Movie> moviesNotPassed = _movies.where(
            (movie) => movie.showings.firstWhere(
                (showing) => showing.date.isAfter(now),
            orElse: () => null
        ) != null).toList();

    String title;
    if (moviesNotPassed.length == 0 && Movie.NOT_YET_POSTED_DAYS.contains(now.weekday)) {
      title = "Last Week's Movies";
    } else {
      title = "This Week's Movies";
    }

    columnChildren.add(new Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: new Center(child: new Text(title, style: MaterialCard.titleStyle))
    ));
    columnChildren.addAll(_movies.map(buildMovie));

    return new Center(
      child: new Scrollbar(
          child: new RefreshIndicator(
              child: new ListView(
                scrollDirection: Axis.vertical,
                children: columnChildren,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () async {
                try {
                  _movies = await movieProvider.retrieveMoviesFromWebAndSave();
                } catch (e) {
                  print('Could not refresh movies from web:');
                  print(e);
                }

                await load();
              })
      ),
    );
  }
}