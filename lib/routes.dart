import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stegify_mobile/screens/home.dart';
import 'package:stegify_mobile/theme.dart';

const String THEME_MODE_PREFERENCES_KEY = "dark_theme";

class Stegify extends StatefulWidget {
  final bool isDarkTheme;

  Stegify({Key key, this.isDarkTheme}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StegifyState(isDarkTheme: this.isDarkTheme);
  }
}

class _StegifyState extends State<Stegify> {
  bool isDarkTheme;

  _StegifyState({this.isDarkTheme});

  @override
  void initState() {
    super.initState();
    _changeSystemUI();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stegify',
      initialRoute: '/',
      routes: {
        '/': (context) => Home(
              isDark: _isDarkTheme,
              changeTheme: _changeTheme,
            ),
      },
      theme: isDarkTheme ? dark : light,
    );
  }

  bool _isDarkTheme() {
    return this.isDarkTheme;
  }

  void _changeTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.isDarkTheme = !this.isDarkTheme;
    });
    prefs.setBool(THEME_MODE_PREFERENCES_KEY, this.isDarkTheme);
    _changeSystemUI();
  }

  void _changeSystemUI() {
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
}
