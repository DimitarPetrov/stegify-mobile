import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

const String THUMBNAILS_DIR = "thumbnails";
const String IMAGES_DIR = "images";

Future<File> generateThumbnail(String path) async {
  ImageProperties properties =
      await FlutterNativeImage.getImageProperties(path);
  return FlutterNativeImage.compressImage(path,
      targetWidth: 500,
      targetHeight: (properties.height * 500 / properties.width).round());
}

Future<File> getOriginalImage(String name) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String imagePath = appDocDir.path + "/" + IMAGES_DIR + "/" + name;
  return File(imagePath);
}

Future<List<Image>> getThumbnails() async {
  return getImagesFromDir(THUMBNAILS_DIR);
}

Future<List<Image>> getImages() async {
  return getImagesFromDir(IMAGES_DIR);
}

Future<List<Image>> getImagesFromDir(String dir) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory home = new Directory(appDocDir.path + "/" + dir);
  return home.list().map((f) => Image.file(f)).toList();
}

void saveImage(File image) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String imagePath =
      appDocDir.path + "/" + IMAGES_DIR + "/" + basename(image.path);
  String thumbnailPath = appDocDir.path +
      "/" +
      THUMBNAILS_DIR +
      "/" +
      basename(image.path) +
      "_th";
  image.copy(imagePath);
  File thumbnail = await generateThumbnail(imagePath);
  thumbnail.copy(thumbnailPath);
}
