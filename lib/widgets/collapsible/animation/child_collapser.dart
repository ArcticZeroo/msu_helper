import 'package:flutter/material.dart';

class ChildCollapser extends StatefulWidget {
  final ValueNotifier<bool> isCollapsed;
  final Widget child;

  ChildCollapser({
    @required this.child,
    ValueNotifier collapseController,
    bool initial = false
  })
      : isCollapsed = collapseController ?? new ValueNotifier(initial);

  void setCollapsed(value) {
    this.isCollapsed.value = value;
  }

  @override
  _ChildCollapserState createState() => new _ChildCollapserState();
}

class _ChildCollapserState extends State<ChildCollapser> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 100)
    );

    if (!widget.isCollapsed.value) {
      showChildren();
    }

    widget.isCollapsed.addListener(updateVisibility);
  }

  @override
  void dispose() {
    widget.isCollapsed.removeListener(updateVisibility);

    super.dispose();
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

  void updateVisibility() {
    if (widget.isCollapsed.value) {
      hideChildren();
    } else {
      showChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: _animationController,
      child: widget.child,
    );
  }
}