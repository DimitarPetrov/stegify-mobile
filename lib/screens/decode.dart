import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stegify_mobile/util/utils.dart';
import 'package:stegify_mobile/widgets/grid.dart';
import 'package:zefyr/zefyr.dart';

class DecodeScreen extends StatefulWidget {
  final File image;
  final RebuildImageGridCallback rebuildGrid;

  DecodeScreen({Key key, this.image, this.rebuildGrid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DecodeScreenState();
  }
}

class DecodeScreenState extends State<DecodeScreen> {
  int tab = 0;

  NotusDocument _document;
  ZefyrController _controller;

  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _document = NotusDocument();
    _controller = ZefyrController(_document);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Decode"),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                this.tab = index;
              });
            },
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
                    child: Image.file(widget.image),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: CupertinoButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'Extract Image',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      bool ok = await decodeImage(widget.image);
                      if (ok) {
                        widget.rebuildGrid();
                        Navigator.of(context).pop();
                      } else {
                        fileNotEncodedDialog(context);
                      }
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    child: Image.file(widget.image),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Theme.of(context).cursorColor,
                      border: new Border.all(
                          width: 3,
                          color: Theme.of(context).dialogBackgroundColor),
                    ),
                    child: _controller == null
                        ? Center(child: CircularProgressIndicator())
                        : ZefyrScaffold(
                            child: ZefyrEditor(
                              padding: EdgeInsets.all(16),
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: false,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: CupertinoButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'Extract Text',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void fileNotEncodedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Encoded file not found!'),
          content: const Text(
              'There is nothing to decode! Make sure that something is previously encoded in the selected file.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
