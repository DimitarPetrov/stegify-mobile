import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

typedef Future DeleteCallback(BuildContext context, List<int> indexes);

class ImageScreen extends StatefulWidget {
  final List<File> images;
  final int index;

  ImageScreen({Key key, this.images, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImageScreenState();
  }
}

class ImageScreenState extends State<ImageScreen> {
  int currentIndex;

  @override
  void initState() {
    setState(() {
      currentIndex = widget.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stegify"),
      ),
      body: PhotoViewGallery.builder(
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(widget.images[index]),
            heroAttributes: PhotoViewHeroAttributes(
              tag: basename(widget.images[index].path),
            ),
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: widget.images.length,
        loadingChild: new Container(
            alignment: FractionalOffset.center,
            child: new CircularProgressIndicator()),
        pageController: PageController(initialPage: widget.index),
        onPageChanged: (newIndex) {
          setState(() {
            this.currentIndex = newIndex;
          });
        },
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
      ),
    );
  }
}
