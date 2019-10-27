import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stegify_mobile/models/event.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:stegify_mobile/screens/image.dart';
import 'package:stegify_mobile/util/utils.dart';

class Grid extends StatefulWidget {
  final Stream<Event> stream;
  final VoidCallback selection;

  Grid({Key key, this.stream, this.selection}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GridState();
  }
}

class GridState extends State<Grid> {
  bool selecting = false;
  List<int> selected = List<int>();

  @override
  void initState() {
    if (widget.stream != null) {
      widget.stream.listen((event) {
        if (event == Event.DELETE) {
          if (selecting) {
            if (selected.isNotEmpty) _onDelete();
          } else {
            setState(() {
              selecting = !selecting;
            });
          }
        } else if (event == Event.SHARE) {
          if (selecting) {
            if (selected.isNotEmpty) _onShare();
          } else {
            setState(() {
              selecting = !selecting;
            });
          }
        } else if (event == Event.SELECTING) {
          setState(() {
            selecting = !selecting;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!selecting) {
      selected.clear();
    }

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
                        child:
                            selecting ? _selectableImage(image) : image.image,
                      ),
                      onTap: () async {
                        if (!this.selecting) {
                          List<File> images = await getImages();
                          images.sort((f1, f2) => extractSequence(f1.path)
                              .compareTo(extractSequence(f2.path)));
                          int seq = await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => ImageScreen(
                                images: images,
                                index: findIndex(images, image.sequence),
                                deleteCallback: _showDeleteDialog,
                              ),
                            ),
                          );
                          if (seq == null) {
                            seq = -1;
                          }
                          while (seq != -1) {
                            images = await getImages();
                            seq = await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => ImageScreen(
                                  images: images,
                                  index: findIndex(images, seq),
                                  deleteCallback: _showDeleteDialog,
                                ),
                              ),
                            );
                          }
                        } else {
                          setState(() {
                            if (selected.contains(image.sequence)) {
                              selected.remove(image.sequence);
                            } else {
                              selected.add(image.sequence);
                            }
                          });
                        }
                      },
                      onLongPress: () async {
                        setState(() {
                          if (!selecting) {
                            selecting = !selecting;
                            widget.selection();
                          }
                        });
                        if (selected.contains(image.sequence)) {
                          selected.remove(image.sequence);
                        } else {
                          selected.add(image.sequence);
                        }
                      },
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _selectableImage(ImageDTO image) {
    return Center(
      child: Stack(
        children: <Widget>[
          image.image,
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.black,
            ),
            child: Checkbox(
              checkColor: Colors.black,
              value: selected.contains(image.sequence),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    selected.add(image.sequence);
                  } else {
                    selected.remove(image.sequence);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onDelete() {
    _showDeleteDialog(selected).then((val) {
      if (val) {
        setState(() {
          selecting = !selecting;
          widget.selection();
        });
      }
    });
  }

  Future _showDeleteDialog(List<int> indexes) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Really delete images?"),
            actions: <Widget>[
              new FlatButton(
                  child: new Text("Yes"),
                  onPressed: () async {
                    for (int sequence in indexes) {
                      deleteImage(sequence);
                    }
                    Navigator.pop(context, true);
                  }),
              new FlatButton(
                child: new Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }

  void _onShare() async {
    Map<String, List<int>> data = new Map();
    for (int seq in selected) {
      String k = seq.toString() + ".jpg";
      File f = await getOriginalImage(seq.toString());
      List<int> v = f.readAsBytesSync();
      data[k] = v;
    }
    await Share.files('images', data, 'image/jpg');
  }
}
