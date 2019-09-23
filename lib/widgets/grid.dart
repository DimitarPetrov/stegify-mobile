import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:stegify_mobile/screens/image.dart';
import 'package:stegify_mobile/util/utils.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageDTO>>(
      future: getThumbnails(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return new Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: new CircularProgressIndicator());
        }
        snapshot.data.sort((i1, i2) => i1.sequence.compareTo(i2.sequence));
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          children: snapshot.data
              .map((image) => GridTile(
                      child: InkWell(
                    child: Hero(
                      tag: image.sequence,
                      child: image.image,
                    ),
                    onTap: () async {
                      List<File> images = await getImages();
                      images.sort((f1, f2) => extractSequence(f1.path)
                          .compareTo(extractSequence(f2.path)));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(
                              images: images,
                              index: findIndex(images, image.sequence)),
                        ),
                      );
                    },
                  )))
              .toList(),
        );
      },
    );
  }
}
