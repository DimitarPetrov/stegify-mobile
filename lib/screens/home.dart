import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stegify"),
      ),
      body: Center(
        child: Text("Hello world!"),
      ),
    );
  }
}
