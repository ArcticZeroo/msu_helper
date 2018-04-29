import 'dart:async';

import 'package:msu_helper/api/json_cache/provider.dart' as jsonCache;
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/page_route.dart';

TimedCacheEntry<List<Movie>> movieCache;

Future<List<Movie>> retrieveMoviesFromWeb() async {
  print('Retrieving movies from web...');
  String url = PageRoute.getMovieNight(PageRoute.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return response.map((r) => Movie.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<Movie>> retrieveMoviesFromDb() async {
  print('Retrieving movies from db...');
  List<dynamic> movieJsonMap = await jsonCache.retrieveJsonFromDb(Identifier.movieNight);

  if (movieJsonMap == null) {
    return null;
  }

  movieJsonMap.forEach((json) => print(json as Map<String, dynamic>));

  return movieJsonMap.map((j) => Movie.fromJson(j as Map<String, dynamic>)).toList();
}

void setCached(List<Movie> movies) {
  print('Adding movies to cache...');
  movieCache = new TimedCacheEntry(movies, expireTime: ExpireTime.THIRTY_MINUTES);
}

Future<List<Movie>> retrieveMovies() async {
  print('Retrieving food truck movies...');

  if (movieCache != null && movieCache.isValid()) {
    print('Returning a valid cached value');
    return movieCache.value;
  }

  List<Movie> fromDb = await retrieveMoviesFromDb();

  if (fromDb != null && fromDb.length != 0) {
    setCached(fromDb);
    return fromDb;
  }

  List<Movie> fromWeb = await retrieveMoviesFromWeb();

  if (fromWeb != null && fromWeb.length != 0) {
    setCached(fromWeb);

    print('Saving movies to db...');
    await jsonCache.saveJsonToDb(Identifier.movieNight, fromWeb);

    return fromWeb;
  }

  return null;
}