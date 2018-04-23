import 'package:json_annotation/json_annotation.dart';

part './movie_showing.g.dart';

@JsonSerializable()
class MovieShowing extends Object with _$MovieShowingSerializerMixin {
  final String location;
  final DateTime date;

  MovieShowing(this.location, int date)
      : this.date = DateTime.fromMillisecondsSinceEpoch(date);

  factory MovieShowing.fromJson(Map<String, dynamic> json) => _$MovieShowingFromJson(json);
}