// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) {
  return new Movie(
      json['title'] as String,
      (json['showings'] as List)
          ?.map((e) => e == null
              ? null
              : new MovieShowing.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['locations'] as List)?.map((e) => e as String)?.toList(),
      json['groupedShowings'] == null
          ? null
          : groupedShowingsFromJson(
              json['groupedShowings'] as Map<String, dynamic>),
      json['special'] as bool)
    ..nextShowing = json['nextShowing'] == null
        ? null
        : new MovieShowing.fromJson(
            json['nextShowing'] as Map<String, dynamic>);
}

abstract class _$MovieSerializerMixin {
  String get title;
  List<MovieShowing> get showings;
  List<String> get locations;
  bool get isSpecial;
  Map<String, List<DateTime>> get groupedShowings;
  MovieShowing get nextShowing;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'showings': showings,
        'locations': locations,
        'special': isSpecial,
        'groupedShowings': groupedShowings == null
            ? null
            : groupedShowingsToJson(groupedShowings),
        'nextShowing': nextShowing
      };
}
