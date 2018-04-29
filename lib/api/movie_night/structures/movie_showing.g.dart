// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_showing.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

MovieShowing _$MovieShowingFromJson(Map<String, dynamic> json) =>
    new MovieShowing(json['location'] as String, json['date'] as int);

abstract class _$MovieShowingSerializerMixin {
  String get location;
  int get time;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'location': location, 'date': time};
}
