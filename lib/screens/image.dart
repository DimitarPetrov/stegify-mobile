import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:stegify_mobile/screens/encode.dart';
import 'package:stegify_mobile/util/utils.dart';

import 'decode.dart';

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
      floatingActionButton: _actionButton(context),
    );
  }

  Widget _actionButton(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.call_merge),
          onTap: () async {
            List<ImageDTO> thumbnails = await getThumbnails();
            thumbnails.sort((i1, i2) => i1.sequence.compareTo(i2.sequence));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EncodeScreen(
                  image: Image.file(widget.images[currentIndex]),
                  thumbnails: thumbnails,
                ),
              ),
            );
          },
          label: 'Encode',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.call_split),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => DecodeScreen(
                  image: Image.file(widget.images[currentIndex]),
                ),
              ),
            );
          },
          label: 'Decode',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
      ],
    );
  }
}
