import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/material_card.dart';

class CollapsibleCard extends StatefulWidget {
  final Widget title;
  final Builder bodyBuilder;

  const CollapsibleCard({Key key, this.title, this.bodyBuilder}) : super(key: key);
  CollapsibleCard.stringTitle({Key key, String title, Builder bodyBuilder})
      : this(key: key, title: new Text(title), bodyBuilder: bodyBuilder);
  CollapsibleCard.staticBody({Key key, Widget title, Widget body})
      : this(key: key, title: title, bodyBuilder: new Builder(builder: (ctx) => body));

  @override
  _CollapsibleCardState createState() => new _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  bool _isCollapsed;

  @override
  Widget build(BuildContext context) {
    return new MaterialCard(
      title: new InkWell(
        child: new Row(
          children: <Widget>[
            widget.title,
            new IconButton(
                icon: new Icon(_isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                onPressed: null,
                tooltip: _isCollapsed ? 'Expand' : 'Collapse'
            )
          ],
        ),
        onTap: () {
          setState(() {
            _isCollapsed = !_isCollapsed;
          });
        },
      ),
      body: _isCollapsed ? null : widget.bodyBuilder.build(context),
    );
  }
}