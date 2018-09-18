import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/movie_night/structures/movie_showing.dart';

part './movie.g.dart';

Map<String, List<DateTime>> groupedShowingsFromJson(Map<String, dynamic> raw) {
  if (raw == null) {
    return null;
  }

  Map<String, List<DateTime>> showings = new Map();

  for (String location in raw.keys) {
    showings[location] = (raw[location] as List<dynamic>).map((i) => DateTime.fromMillisecondsSinceEpoch(i as int)).toList();
  }

  return showings;
}

Map<String, dynamic> groupedShowingsToJson(Map<String, List<DateTime>> groupedShowings) {
  return groupedShowings == null
      ? null
      : new Map<String, dynamic>.fromIterables(
      groupedShowings.keys,
      groupedShowings.values
          .map((e) => e?.map((e) => e?.millisecondsSinceEpoch)?.toList()));
}

@JsonSerializable()
class Movie extends Object with _$MovieSerializerMixin {
  static const NOT_YET_POSTED_DAYS = [DateTime.monday, DateTime.tuesday, DateTime.wednesday];

  final String title;
  final List<MovieShowing> showings;
  final List<String> locations;

  @JsonKey(name: 'special')
  final bool isSpecial;

  @JsonKey(fromJson: groupedShowingsFromJson, toJson: groupedShowingsToJson)
  final Map<String, List<DateTime>> groupedShowings;

  MovieShowing nextShowing;

  Movie(String title, this.showings, this.locations, this.groupedShowings, this.isSpecial)
    : this.title = title.trim();

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  static MovieShowing findLatestShowing(List<Movie> fromMovies) {
    MovieShowing latestShowing;
    for (Movie movie in fromMovies) {
      if (movie.showings == null || movie.showings.isEmpty) {
        continue;
      }

      // Copy it so we don't modify the original ref
      var showings = List.of(movie.showings);

      showings.sort((a, b) => b.date.compareTo(a.date));

      if (latestShowing == null || latestShowing.date.isBefore(showings.first.date)) {
        latestShowing = showings.first;
      }
    }

    return latestShowing;
  }
}