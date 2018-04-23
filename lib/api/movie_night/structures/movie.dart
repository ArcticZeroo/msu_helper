import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/movie_night/structures/movie_showing.dart';

part './movie.g.dart';

@JsonSerializable()
class Movie extends Object with _$MovieSerializerMixin {
  final String title;
  final List<MovieShowing> showings;
  final List<String> locations;
  final Map<String, List<DateTime>> groupedShowings;
  MovieShowing nextShowing;

  Movie(this.title, this.showings, this.locations, Map<String, List<int>> groupedShowings)
    : this.groupedShowings = groupedShowings.map(
          (String key, List<int> times) => new MapEntry(key, times.map((time) => DateTime.fromMillisecondsSinceEpoch(time))));

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}

