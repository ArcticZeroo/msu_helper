import 'package:flutter/material.dart';

class ErrorCardWidget extends StatelessWidget {
  final String text;

  ErrorCardWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child:  new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Text(text, style: new TextStyle(color: Colors.white)),
        decoration: new BoxDecoration(
            color: Colors.red[900],
            borderRadius: const BorderRadius.all(const Radius.circular(8.0))
        ),
      ),
    );
  }
}