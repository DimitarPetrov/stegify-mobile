import 'package:flutter/material.dart';

class EncodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Encode"),
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
            // TODO: encode photo
            Icon(Icons.photo),
            // TODO: encode text
            Icon(Icons.text_fields),
          ],
        ),
      ),
    );
  }
}
