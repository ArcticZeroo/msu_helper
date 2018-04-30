import 'package:flutter/cupertino.dart';

class WrappableText extends StatelessWidget {
  final Text text;

  WrappableText(this.text);

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: new Column(
        children: <Widget>[text],
      ),
    );
  }
}