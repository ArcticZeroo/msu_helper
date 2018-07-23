import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/preloading/preloading_status.dart';

typedef Future AsyncLoader();

class PreloadingWidget extends StatefulWidget {
  final String text;
  final ValueNotifier<Future> future = new ValueNotifier(null);
  final AsyncLoader _loader;

  PreloadingWidget(this.text, [this._loader]);

  Future start() async {
    if (_loader == null) {
      return null;
    }

    Future loading = _loader();

    future.value = loading;

    return loading;
  }

  @override
  State<StatefulWidget> createState() => new PreloadingWidgetState();
}

class PreloadingWidgetState extends State<PreloadingWidget> {
  @override
  void initState() {
    widget.future.addListener(() => setState(() {}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: widget.future.value,
      builder: (ctx, snapshot) => new PreloadingStatusWidget(widget.text, snapshot),
    );
  }
}