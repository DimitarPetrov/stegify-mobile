import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:stegify_mobile/screens/encode.dart';
import 'package:stegify_mobile/util/utils.dart';
import 'package:stegify_mobile/widgets/grid.dart';

import 'decode.dart';

typedef Future DeleteCallback(List<int> indexes);

class ImageScreen extends StatefulWidget {
  final List<File> images;
  final int index;
  final DeleteCallback deleteCallback;
  final RebuildImageGridCallback rebuildGrid;

  ImageScreen({Key key, this.images, this.index, this.deleteCallback, this.rebuildGrid})
      : super(key: key);

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              int sequence = extractSequence(widget.images[currentIndex].path);
              File f = await getOriginalImage(sequence.toString());
              await Share.file(
                  sequence.toString(),
                  sequence.toString() + ".jpg",
                  f.readAsBytesSync(),
                  'image/jpg');
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.deleteCallback(<int>[
                extractSequence(widget.images[currentIndex].path)
              ]).then((val) {
                if (val) {
                  Navigator.pop(context);
                }
              });
            },
          )
        ],
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
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
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
            bool ok = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EncodeScreen(
                  image: widget.images[currentIndex],
                  thumbnails: thumbnails,
                  rebuildGrid: widget.rebuildGrid
                ),
              ),
            );
            if (ok != null && ok) {
              Navigator.pop(context);
            }
          },
          label: 'Encode',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.call_split),
          onTap: () async {
            int seq = await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => DecodeScreen(
                  image: widget.images[currentIndex],
                ),
              ),
            );
            if (seq != null && seq != -1) {
              Navigator.of(context).pop(seq);
            }
          },
          label: 'Decode',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
      ],
    );
  }
}
