import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/material_card.dart';

class LoadingWidget extends StatelessWidget {
  final String name;

  const LoadingWidget({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) => new Center(
    child: new Container(
      decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
      padding: const EdgeInsets.all(16.0),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new SizedBox(
            width: 24.0,
            height: 24.0,
            child: new CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
          new Container(width: 16.0),
          new Text('Loading${name != null ? ' $name' : ''}...', style: const TextStyle(color: Colors.white, fontSize: 16.0))
        ],
      ),
    ),
  );
}