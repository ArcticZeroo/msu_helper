import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/widgets/preloading/preloading_status.dart';

enum FutureStatus {
  // idle is not yet run, running is once it's been called
  idle, preload, running, done, failed
}

typedef Future AsyncLoader();

class PreloadingWidget extends StatefulWidget {
  final ValueNotifier<FutureStatus> status = new ValueNotifier<FutureStatus>(FutureStatus.idle);
  final String text;
  final AsyncLoader load;

  PreloadingWidget(this.text, this.load);

  @override
  State<StatefulWidget> createState() => new PreloadingWidgetState();
}

class PreloadingWidgetState extends State<PreloadingWidget> {
  @override
  void initState() {
    widget.status.addListener(() {
      this.setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status.value == FutureStatus.preload) {
      widget.status.value = FutureStatus.running;

      widget.load()
          .then((_) {
        widget.status.value = FutureStatus.done;
      })
          .catchError((e) {
        widget.status.value = FutureStatus.failed;
      });
    }

    return new PreloadingStatusWidget(widget.text, widget.status.value);
  }
}