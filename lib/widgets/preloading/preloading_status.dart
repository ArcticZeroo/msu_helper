import 'package:flutter/material.dart';

class PreloadingStatusWidget extends StatelessWidget {
  final double _iconSize = 24.0;

  final String _text;
  final AsyncSnapshot _status;

  PreloadingStatusWidget(this._text, this._status);

  Widget buildCircleAvatar(Color backgroundColor, [Widget child]) {
    return new CircleAvatar(
      backgroundColor: backgroundColor,
      minRadius: _iconSize / 2,
      maxRadius: _iconSize / 2,
      child: child,
    );
  }

  Widget buildProgressIndicator([Color lineColor]) {
    return new SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(lineColor)),
    );
  }

  Widget getStatusIcon(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.active:
      case ConnectionState.waiting:
        return buildProgressIndicator();
      case ConnectionState.done:
        Color color = snapshot.hasError ? Colors.redAccent : Colors.green;
        IconData icon = snapshot.hasError ? Icons.close : Icons.done;

        return buildCircleAvatar(
            color,
            new Icon(
              icon,
              color: Colors.white,
              size: _iconSize * 0.75,
            )
        );
      default:
        // Yeah this is stupid, but it's easier than writing a bunch of
        // unnecessary padding around just an Icon so I can have a little
        // dot inside the same radius as the other circle avatars
        return buildCircleAvatar(
            Colors.white,
            new Icon(Icons.fiber_manual_record, color: Colors.grey[400])
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(16.0),
          child: getStatusIcon(_status),
        ),
        new Text(_text, style: new TextStyle(fontSize: 16.0))
      ],
    );
  }
}