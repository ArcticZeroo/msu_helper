// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_showing.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

MovieShowing _$MovieShowingFromJson(Map<String, dynamic> json) =>
    new MovieShowing(json['location'] as String, json['date'] as int);

abstract class _$MovieShowingSerializerMixin {
  String get location;
  DateTime get date;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'location': location, 'date': date?.toIso8601String()};
}
