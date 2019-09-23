import 'package:flutter/material.dart';
import 'package:stegify_mobile/util/utils.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Image>>(
      future: getThumbnails(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return new Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: new CircularProgressIndicator());
        }
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          children: snapshot.data
              .map((image) => GridTile(
                    child: image,
                  ))
              .toList(),
        );
      },
    );
  }
}
