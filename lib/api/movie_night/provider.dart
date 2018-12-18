import 'dart:async';

import 'package:msu_helper/api/json_cache/provider.dart' as jsonCache;
import 'package:msu_helper/api/movie_night/structures/movie.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/page_route_config.dart';
import 'package:synchronized/synchronized.dart';

TimedCacheEntry<List<Movie>> movieCache;
Lock movieLock = new Lock();

Future<List<Movie>> retrieveMoviesFromWeb() async {
  String url = PageRouteConfig.getMovieNight(PageRouteConfig.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return response.map((r) => Movie.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<Movie>> retrieveMoviesFromWebAndSave() async {
  List<Movie> fromWeb = await retrieveMoviesFromWeb();

  if (fromWeb != null && fromWeb.isNotEmpty) {
    setCached(fromWeb);

    await jsonCache.saveJsonToDb(Identifier.movieNight, fromWeb);

    return fromWeb;
  }

  return null;
}

Future<List<Movie>> retrieveMoviesFromDb() async {
  List<dynamic> movieJsonMap = await jsonCache.retrieveJsonFromDb(Identifier.movieNight);

  if (movieJsonMap == null) {
    return null;
  }

  return movieJsonMap.map((j) => Movie.fromJson(j as Map<String, dynamic>)).toList();
}

void setCached(List<Movie> movies) {
  movieCache = new TimedCacheEntry(movies, expireTime: ExpireTime.THIRTY_MINUTES);
}

Future<List<Movie>> retrieveMovies() async {
  return movieLock.synchronized(() async {
    if (movieCache != null && movieCache.isValid()) {
      return List.unmodifiable(movieCache.value);
    }

    List<Movie> fromDb = await retrieveMoviesFromDb();

    if (fromDb != null && fromDb.isNotEmpty) {
      setCached(fromDb);
      return List.unmodifiable(fromDb);
    }

    var movies = await retrieveMoviesFromWebAndSave();

    return List.unmodifiable(movies);
  });
}