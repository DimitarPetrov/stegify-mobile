import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stegify_mobile/screens/home.dart';
import 'package:stegify_mobile/theme.dart';

class Stegify extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StegifyState();
  }
}

class _StegifyState extends State<Stegify> {
  bool isDarkTheme = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkTheme ? dark.primaryColor : light.primaryColor,
      statusBarIconBrightness: isDarkTheme ? dark.brightness : light.brightness,
      systemNavigationBarColor:
          isDarkTheme ? dark.primaryColor : light.primaryColor,
      systemNavigationBarIconBrightness:
          isDarkTheme ? light.brightness : dark.brightness,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stegify',
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
      },
      theme: isDarkTheme ? dark : light,
    );
  }
}
