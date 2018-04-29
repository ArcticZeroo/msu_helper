// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => new Movie(
    json['title'] as String,
    (json['showings'] as List)
        ?.map((e) => e == null
            ? null
            : new MovieShowing.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['locations'] as List)?.map((e) => e as String)?.toList(),
    json['groupedShowings'] == null
        ? null
        : new Map<String, List<int>>.fromIterables(
            (json['groupedShowings'] as Map<String, dynamic>).keys,
            (json['groupedShowings'] as Map)
                .values
                .map((e) => (e as List)?.map((e) => e as int)?.toList())))
  ..nextShowing = json['nextShowing'] == null
      ? null
      : new MovieShowing.fromJson(json['nextShowing'] as Map<String, dynamic>);

abstract class _$MovieSerializerMixin {
  String get title;
  List<MovieShowing> get showings;
  List<String> get locations;
  Map<String, List<DateTime>> get groupedShowings;
  MovieShowing get nextShowing;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'showings': showings,
        'locations': locations,
        'groupedShowings': groupedShowings == null
            ? null
            : new Map<String, dynamic>.fromIterables(
                groupedShowings.keys,
                groupedShowings.values
                    .map((e) => e?.map((e) => e?.millisecondsSinceEpoch)?.toList())),
        'nextShowing': nextShowing
      };
}
