import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/movie_night/structures/movie_showing.dart';

part './movie.g.dart';

@JsonSerializable()
class Movie extends Object with _$MovieSerializerMixin {
  static const NOT_YET_POSTED_DAYS = [DateTime.monday, DateTime.tuesday, DateTime.wednesday];

  final String title;
  final List<MovieShowing> showings;
  final List<String> locations;
  final Map<String, List<DateTime>> groupedShowings;
  MovieShowing nextShowing;

  Movie(String title, this.showings, this.locations, Map<String, List<int>> groupedShowings)
    : this.title = title.trim(), this.groupedShowings = Movie.buildGroupedShowings(groupedShowings);

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  static Map<String, List<DateTime>> buildGroupedShowings(Map<String, List<int>> raw) {
    Map<String, List<DateTime>> showings = new Map();

    for (String location in raw.keys) {
      showings[location] = raw[location].map((i) => DateTime.fromMillisecondsSinceEpoch(i)).toList();
    }

    return showings;
  }
}