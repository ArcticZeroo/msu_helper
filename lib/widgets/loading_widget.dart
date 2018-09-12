import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String name;

  const LoadingWidget({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) => new Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      new Container(
        padding: const EdgeInsets.all(8.0),
        child: new CircularProgressIndicator(),
      ),
      new Text('Loading${name != null ? ' $name' : ''}...')
    ],
  );
}