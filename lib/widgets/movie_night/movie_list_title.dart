import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/material_card.dart';

class MovieListTitle extends StatelessWidget {
  final String text;

  const MovieListTitle(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 16.0),
    child: Center(
      child: Text(text, style: MaterialCard.titleStyle)
    )
  );
}