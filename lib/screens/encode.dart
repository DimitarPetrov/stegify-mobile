import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:stegify_mobile/util/utils.dart';

class EncodeScreen extends StatefulWidget {
  final Image image;
  final List<ImageDTO> thumbnails;

  EncodeScreen({Key key, this.image, this.thumbnails}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EncodeScreenState(this.thumbnails);
  }
}

class EncodeScreenState extends State<EncodeScreen> {
  int index = -1;
  bool checkMark = false;
  List<ImageDTO> thumbnails;

  EncodeScreenState(this.thumbnails);

  @override
  Widget build(BuildContext context) {
    double radius = (MediaQuery.of(context).size.height / 100) * 7;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Encode"),
          actions: <Widget>[
            checkMark
                ? IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      // TODO: encode image
                    },
                  )
                : SizedBox.shrink(),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.photo),
              ),
              Tab(
                icon: Icon(Icons.text_fields),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    child: widget.image,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: thumbnails.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == thumbnails.length) {
                        return InkWell(
                          borderRadius: new BorderRadius.circular(radius),
                          child: CircleAvatar(
                            radius: radius,
                            backgroundColor: Theme.of(context).hintColor,
                            child: Text(
                              "+",
                              style: TextStyle(fontSize: radius),
                            ),
                          ),
                          onTap: _openGallery,
                        );
                      }
                      return Container(
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(radius),
                          border: new Border.all(
                            width: 3,
                            color: checkMark && this.index == index
                                ? Theme.of(context).buttonColor
                                : Theme.of(context).backgroundColor,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: new BorderRadius.circular(radius),
                          child: CircleAvatar(
                            radius: radius,
                            backgroundImage: thumbnails[index].image.image,
                          ),
                          onTap: () {
                            setState(() {
                              if (this.index == index) {
                                this.index = -1;
                                this.checkMark = false;
                              } else {
                                this.index = index;
                                this.checkMark = true;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            // TODO: encode text
            Icon(Icons.text_fields),
          ],
        ),
      ),
    );
  }

  void _openGallery() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      await saveImage(image);
      // Reload images after adding a new one.
      List<ImageDTO> thumbnails = await getThumbnails();
      thumbnails.sort((i1, i2) => i1.sequence.compareTo(i2.sequence));
      setState(() {
        this.thumbnails = thumbnails;
      });
    }
  }
}
