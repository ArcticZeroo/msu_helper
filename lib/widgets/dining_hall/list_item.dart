import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/relevant.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/pages/dining_hall/menu_page.dart';
import 'package:msu_helper/util/ListUtil.dart';

class DiningHallListItem extends StatelessWidget {
  final DiningHall diningHall;

  const DiningHallListItem(this.diningHall);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: const Offset(0.0, 1.0),
              blurRadius: 4.0
            )
          ]
        ),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: ListUtil.add(
            [Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Center(
                child: Text(diningHall.hallName,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500
                  )
                )),
            )],
            // TODO: Refactor
            getSuperRelevantLines(diningHall)
              .map((s) => Center(child: Text(s)))
              .toList()
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new HallInfoPage(diningHall)
          )
        );
      },
    );
  }
}

class FavoriteDiningHallListItem extends StatelessWidget {
  final DiningHall diningHall;

  FavoriteDiningHallListItem(this.diningHall);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(6.0),
              child: Icon(Icons.star, color: Colors.yellow),
            ),
            Text('Favorite Hall')
          ],
        ),
        DiningHallListItem(diningHall),
        Divider()
      ],
    );
  }
}