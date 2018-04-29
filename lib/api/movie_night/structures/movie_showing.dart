import 'package:json_annotation/json_annotation.dart';

part './movie_showing.g.dart';

@JsonSerializable()
class MovieShowing extends Object with _$MovieShowingSerializerMixin {
  final String location;
  @JsonKey(name: 'date')
  final int time;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(time);

  MovieShowing(this.location, this.time);

  factory MovieShowing.fromJson(Map<String, dynamic> json) => _$MovieShowingFromJson(json);
}