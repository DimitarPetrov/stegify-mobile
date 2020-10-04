import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  if (!File(appDocDir.path + "/street.jpeg").existsSync()) {
    File street = await copyImageFromAsset("street.jpeg");
    await saveImage(street);
  }

  if (!File(appDocDir.path + "/lake.jpeg").existsSync()) {
    File lake = await copyImageFromAsset("lake.jpeg");
    await saveImage(lake);
  }

  runApp(Stegify(
    isDarkTheme: isDarkTheme,
  ));
}

Future<File> copyImageFromAsset(String imageName) async {
  Directory directory = await getApplicationDocumentsDirectory();
  ByteData data = await rootBundle.load("assets/" + imageName);
  List<int> bytes =
  data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  File image = File(directory.path + "/" + imageName);
  image.writeAsBytes(bytes);
  return image;
}