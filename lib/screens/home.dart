import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stegify_mobile/models/event.dart';
import 'package:stegify_mobile/util/utils.dart';
import 'package:stegify_mobile/widgets/grid.dart';

typedef bool IsDarkThemeCallback();
typedef void ChangeThemeCallback();

class Home extends StatefulWidget {
  final IsDarkThemeCallback isDark;
  final ChangeThemeCallback changeTheme;

  Home({Key key, this.isDark, this.changeTheme}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); // ADD THIS LINE
  bool selecting = false;
  StreamController<Event> _controller = StreamController<Event>();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Stegify"),
        leading: selecting
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selecting = !selecting;
                    _controller.add(Event.SELECTING);
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: "Delete",
            onPressed: () {
              setState(() {
                if (!selecting) {
                  setState(() {
                    selecting = !selecting;
                  });
                }
                _controller.add(Event.DELETE);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: "Share",
            onPressed: () {
              setState(() {
                if (!selecting) {
                  setState(() {
                    selecting = !selecting;
                  });
                }
                _controller.add(Event.SHARE);
              });
            },
          ),
        ],
      ),
      body: Grid(
          stream: _controller.stream,
          selection: () {
            setState(() {
              selecting = !selecting;
            });
          }),
      drawer: _drawer(),
      floatingActionButton: _actionButton(),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              "Stegify",
              style:
                  Theme.of(context).textTheme.headline6.apply(fontSizeDelta: 4),
            ),
            accountEmail: Text(
                "Developer Contact: d.n.petrovv@gmail.com"), // TODO: Rate ot Google play!
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Text(
                "S",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_3),
            title: Text(
              "Dark Mode",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .apply(fontSizeDelta: 2, fontWeightDelta: 2),
            ),
            trailing: Switch(
              value: widget.isDark(),
              onChanged: (val) {
                widget.changeTheme();
              },
            ),
            onTap: widget.changeTheme,
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _actionButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add_a_photo),
          onTap: _openCamera,
          label: 'Take a photo',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_photo_alternate),
          onTap: _openGallery,
          label: 'Select from Gallery',
          labelStyle: Theme.of(context).textTheme.button,
          labelBackgroundColor: Theme.of(context).backgroundColor,
        ),
      ],
    );
  }

  void _openCamera() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedImage = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      File image = File(pickedImage.path);
      await saveImage(image);
      // Reload images after adding a new one.
      setState(() {});
    }
  }

  void _openGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedImage = await imagePicker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      File image = File(pickedImage.path);
      await saveImage(image);
      // Reload images after adding a new one.
      setState(() {});
    }
  }
}
