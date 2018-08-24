import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/collapsible/animation/child_collapser.dart';

class CollapsibleCustom extends StatefulWidget {
  final Widget title;
  final Widget body;
  final ValueNotifier<bool> isCollapsed;
  final ValueNotifier<bool> isEnabled;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  CollapsibleCustom({
    Key key,
    this.title,
    this.body,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    ValueNotifier collapseController,
    bool isEnabled = true,
    bool initial = false
  }) :
        this.isCollapsed = collapseController ?? new ValueNotifier(initial),
        this.isEnabled = new ValueNotifier(isEnabled),
        super(key: key);

  void setEnabled(bool value) {
    this.isEnabled.value = value;
  }

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

    widget.isCollapsed.addListener(() { print('Widget isCollapsed has changed to ${widget.isCollapsed.value}'); });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: widget.crossAxisAlignment ?? CrossAxisAlignment.center,
      children: <Widget>[
        new InkWell(
          child: widget.title,
          onTap: () {
            // print('Ink well was tapped at ${DateTime.now().millisecondsSinceEpoch}, and isCollapsed is ${widget.isCollapsed.value ? 'collapsed' : 'shown'}');

            if (!widget.isEnabled.value) {
              return;
            }

            setState(() {
              widget.isCollapsed.value = !widget.isCollapsed.value;
            });
          },
        ),
        _childCollapser
      ],
    );
  }
}