import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stegify_mobile/routes.dart';
import 'package:stegify_mobile/util/utils.dart';

void main() async {

  Directory appDocDir = await getApplicationDocumentsDirectory();
  new Directory(appDocDir.path + "/" + IMAGES_DIR).create();
  new Directory(appDocDir.path + "/" + THUMBNAILS_DIR).create();

  runApp(Stegify());
}
