import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/material_card.dart';

class CollapsibleCard extends StatefulWidget {
  final Widget title;
  final Widget body;
  final Color backgroundColor;
  final Color arrowColor;
  final ValueNotifier<bool> isCollapsed;

  CollapsibleCard({
    Key key,
    @required
    this.title,
    @required
    this.body,
    this.backgroundColor,
    this.arrowColor,
    bool initial = false
  }) :
        this.isCollapsed = new ValueNotifier(initial),
        super(key: key);

  @override
  _CollapsibleCardState createState() => new _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  _CollapsibleCardState() {
    _animationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 100)
    );
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isCollapsed.value) {
      showChildren();
    }
  }

  void showChildren() {
    if (_animationController.value == 0) {
      _animationController.forward();
    }
  }

  void hideChildren() {
    if (_animationController.value != 0) {
      _animationController.reverse();
    }
  }

  void updateChildrenVisibility() {
    if (widget.isCollapsed.value) {
      hideChildren();
    } else {
      showChildren();
    }
  }

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
                icon: new Icon(
                    widget.isCollapsed.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: widget.arrowColor
                ),
                onPressed: null,
                tooltip: widget.isCollapsed.value ? 'Expand' : 'Collapse'
            )
          ],
        ),
        onTap: () {
          setState(() {
            widget.isCollapsed.value = !widget.isCollapsed.value;
            updateChildrenVisibility();
          });
        },
      ),
      body: new SizeTransition(
        sizeFactor: _animationController,
        child: widget.body,
      ),
    );
  }
}