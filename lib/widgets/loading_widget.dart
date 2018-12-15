import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
    final String name;
    final bool centered;

    const LoadingWidget({
        Key key,
        this.name,
        this.centered = true
    }) : super(key: key);

    Widget buildLoadingOnly(BuildContext context) => Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(4.0)
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0
                  )
                ),
                Text(
                    'Loading${name == null ? '' : ' $name'}...',
                    style: TextStyle(
                      color: Colors.white
                    ),
                )
            ],
        ),
    );

    @override
    Widget build(BuildContext context) => centered
      ? Center(child: buildLoadingOnly(context))
      : buildLoadingOnly(context);
}