import 'package:flutter/material.dart';

class VisibilityToggleWidget extends StatefulWidget {
  final ValueNotifier<bool> _isVisibleController;
  final Widget child;

  VisibilityToggleWidget({
    @required
    this.child,
    bool isInitiallyVisible = true
  }) : _isVisibleController = new ValueNotifier(isInitiallyVisible) {
    _isVisibleController.addListener(() { print('visibility is now $isVisible'); });
  }

  bool get isVisible => _isVisibleController.value;
  set isVisible (visible) => _isVisibleController.value = visible;

  @override
  State<StatefulWidget> createState() => new _VisibilityToggleState();
}

class _VisibilityToggleState extends State<VisibilityToggleWidget> {
  @override
  void initState() {
    super.initState();

    widget._isVisibleController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Opacity(
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: widget.child
    );
  }
}