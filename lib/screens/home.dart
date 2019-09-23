import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stegify"),
      ),
      body: Grid(),
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
              style: Theme.of(context).textTheme.title.apply(fontSizeDelta: 4),
            ),
            accountEmail: Text("Developer Contact: d.n.petrovv@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Text(
                "S",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Text(
              "Dark Mode",
              style: Theme.of(context)
                  .textTheme
                  .subtitle
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
    File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      await saveImage(image);
      // Reload images after adding a new one.
      setState(() {});
    }
  }

  void _openGallery() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      await saveImage(image);
      // Reload images after adding a new one.
      setState(() {});
    }
  }
}
