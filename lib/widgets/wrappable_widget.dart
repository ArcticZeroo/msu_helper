import 'package:flutter/cupertino.dart';

class WrappableWidget extends StatelessWidget {
  final Widget widget;

  WrappableWidget(this.widget);

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: widget is Column ? widget : new Column(
        children: <Widget>[widget],
      ),
    );
  }
}