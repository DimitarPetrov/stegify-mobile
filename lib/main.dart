import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stegify_mobile/routes.dart';
import 'package:stegify_mobile/util/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory appDocDir = await getApplicationDocumentsDirectory();
  new Directory(appDocDir.path + "/" + IMAGES_DIR).create();
  new Directory(appDocDir.path + "/" + THUMBNAILS_DIR).create();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkTheme = prefs.getBool(THEME_MODE_PREFERENCES_KEY) ?? true;

  runApp(Stegify(
    isDarkTheme: isDarkTheme,
  ));
}
