import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/preloading/preload_widget.dart';

class PreloadingStatusWidget extends StatelessWidget {
  final double _iconSize = 24.0;

  final String _text;
  final FutureStatus _status;

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

  Widget getStatusIcon(FutureStatus status) {
    switch (status) {
      case FutureStatus.running:
        return buildProgressIndicator();
      case FutureStatus.done:
        return buildCircleAvatar(Colors.green, new Icon(
          Icons.done,
          color: Colors.white,
          size: _iconSize * 0.75,
        ));
      case FutureStatus.failed:
        return buildCircleAvatar(Colors.redAccent, new Icon(
          Icons.close,
          color: Colors.white,
          size: _iconSize * 0.75,
        ));
      case FutureStatus.idle:
      default:
        return buildProgressIndicator(Colors.grey[400]);
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