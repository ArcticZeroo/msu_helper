import 'package:flutter/material.dart';

class StopSectionTitleWidget extends StatelessWidget {
  static final TextStyle titleStyle = const TextStyle(
    fontSize: 24.0,
    color: Colors.black87,
    fontWeight: FontWeight.w500
  );

  final String title;

  StopSectionTitleWidget(this.title);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8.0),
    child: Center(child: new Text(title, style: titleStyle)),
  );
}