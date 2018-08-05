import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/collapsible/animation/child_collapser.dart';

class CollapsibleCustom extends StatefulWidget {
  final Widget title;
  final Widget body;
  final ValueNotifier<bool> isCollapsed;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  CollapsibleCustom({
    Key key,
    this.title,
    this.body,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    bool initial = false
  }) :
        this.isCollapsed = new ValueNotifier(initial),
        super(key: key);

  @override
  _CollapsibleCustomState createState() => new _CollapsibleCustomState();
}

class _CollapsibleCustomState extends State<CollapsibleCustom> {
  ChildCollapser _childCollapser;

  @override
  void initState() {
    super.initState();

    _childCollapser = new ChildCollapser(
      child: widget.body,
      initial: widget.isCollapsed.value,
      collapseController: widget.isCollapsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: <Widget>[
        new InkWell(
          child: widget.title,
          onTap: () {
            widget.isCollapsed.value = !widget.isCollapsed.value;
          },
        ),
        _childCollapser
      ],
    );
  }
}