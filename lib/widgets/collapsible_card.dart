import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/material_card.dart';

class CollapsibleCard extends StatefulWidget {
  final Widget title;
  final Widget body;
  final Color backgroundColor;
  final ValueNotifier<bool> isCollapsed;

  CollapsibleCard({
    Key key,
    this.title,
    this.body,
    this.backgroundColor,
    bool initial = false
  }) :
        this.isCollapsed = new ValueNotifier(initial),
        super(key: key);

  @override
  _CollapsibleCardState createState() => new _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  @override
  Widget build(BuildContext context) {
    return new MaterialCard(
      backgroundColor: widget.backgroundColor,
      title: new InkWell(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.title,
            new IconButton(
                icon: new Icon(widget.isCollapsed.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                onPressed: null,
                tooltip: widget.isCollapsed.value ? 'Expand' : 'Collapse'
            )
          ],
        ),
        onTap: () {
          setState(() {
            widget.isCollapsed.value = !widget.isCollapsed.value;
          });
        },
      ),
      body: widget.isCollapsed.value ? null : widget.body,
    );
  }
}