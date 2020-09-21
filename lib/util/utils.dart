import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_stegify/flutter_stegify.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stegify_mobile/models/image.dart';
import 'package:path/path.dart';

const String SHARED_PREFERENCES_SEQUENCE_KEY = "sequence";
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

int extractSequence(String path) {
  return int.parse(basename(path));
}

Future<List<ImageDTO>> getThumbnails() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory home = new Directory(appDocDir.path + "/" + THUMBNAILS_DIR);
  return home
      .list()
      .map((f) =>
          ImageDTO(image: Image.file(f), sequence: extractSequence(f.path)))
      .toList();
}

Future<List<File>> getImages() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory topicHome = new Directory(appDocDir.path + "/" + IMAGES_DIR);
  return topicHome.list().map((f) => File(f.path)).toList();
}

int findIndex(List<File> images, int sequence) {
  for (int i = 0; i < images.length; ++i) {
    if (extractSequence(images[i].path) == sequence) {
      return i;
    }
  }
  return -1;
}

void saveImage(File image) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  SharedPreferences pref = await SharedPreferences.getInstance();

  int sequence = pref.getInt(SHARED_PREFERENCES_SEQUENCE_KEY) ?? 0;
  ++sequence;

  String imagePath =
      appDocDir.path + "/" + IMAGES_DIR + "/" + sequence.toString();
  String thumbnailPath =
      appDocDir.path + "/" + THUMBNAILS_DIR + "/" + sequence.toString();
  image.copy(imagePath);

  File thumbnail = await generateThumbnail(image.path);
  await thumbnail.copy(thumbnailPath);

  pref.setInt(SHARED_PREFERENCES_SEQUENCE_KEY, sequence);
}

void deleteImage(int sequence) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  deleteImageByDirectory(
      new Directory(appDocDir.path + '/' + IMAGES_DIR), sequence);
  deleteImageByDirectory(
      new Directory(appDocDir.path + '/' + THUMBNAILS_DIR), sequence);
}

void deleteImageByDirectory(Directory directory, int sequence) {
  File.fromUri(directory.uri.resolve(sequence.toString()))
      .deleteSync(recursive: true);
}

typedef void EncodeCallback(bool);

void encodeImage(File carrier, File data, EncodeCallback callback) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  SharedPreferences pref = await SharedPreferences.getInstance();
  int sequence = pref.getInt(SHARED_PREFERENCES_SEQUENCE_KEY) ?? 0;
  ++sequence;
  String resultPath =
      appDocDir.path + "/" + IMAGES_DIR + "/" + sequence.toString();
  
  final isolates = IsolateHandler();
  isolates.spawn<List<String>>(entryPoint,
      name: "encoder",
      // Executed every time data is received from the spawned isolate.
      onReceive: (result) async {
        isolates.kill("encoder");

        String thumbnailPath =
            appDocDir.path + "/" + THUMBNAILS_DIR + "/" + sequence.toString();
        File thumbnail = await generateThumbnail(resultPath);
        thumbnail.copySync(thumbnailPath);
        pref.setInt(SHARED_PREFERENCES_SEQUENCE_KEY, sequence);

        callback(result[0] == "true");
      },
      // Executed once when spawned isolate is ready for communication.
      onInitialized: () =>
          isolates.send([carrier.path, data.path, resultPath], to: "encoder"));
}

void entryPoint(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  // Triggered every time data is received from the main isolate.
  messenger.listen((paths) async {
    paths = paths as List<String>;
    bool result = true;
    try {
      await Stegify.encode(paths[0], paths[1], paths[2]);
    } catch (err) {
      if (err.message.contains("data file too large for this carrier")) {
        result = false;
      } else {
        throw err;
      }
    }
    // Add one to the count and send the new value back to the main
    // isolate.
    messenger.send([result.toString()]);
  });
}

Future<int> decodeImage(File carrier) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  SharedPreferences pref = await SharedPreferences.getInstance();

  int sequence = pref.getInt(SHARED_PREFERENCES_SEQUENCE_KEY) ?? 0;
  ++sequence;

  String resultPath =
      appDocDir.path + "/" + IMAGES_DIR + "/" + sequence.toString();

  await Stegify.decode(carrier.path, resultPath);

  String thumbnailPath =
      appDocDir.path + "/" + THUMBNAILS_DIR + "/" + sequence.toString();

  File thumbnail = await generateThumbnail(resultPath);
  await thumbnail.copy(thumbnailPath);

  pref.setInt(SHARED_PREFERENCES_SEQUENCE_KEY, sequence);
  return sequence;
}
