import 'package:flutter/services.dart' show rootBundle;

import 'package:firebase_storage/firebase_storage.dart';

import 'dart:math';

import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

class ProfilePicture {
  Future<Null> uploadFile(String fileName, File file) async {
    // final ByteData bytes = await rootBundle.load(filepath);
    // final Directory tempDir = Directory.systemTemp;
    // final String fileName = "${Random().nextInt(10000)}.jpg";
    // final File file = File('${tempDir.path}/$fileName');
    // file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask task = ref.putFile(file);
  }

  Future<File> downloadFile(String uid, bool cache, bool hasProfilePic) async {
    if (hasProfilePic) {
      File file;
      if (cache == true) {
        final Directory tempDir = Directory.systemTemp;
        File('${tempDir.path}/$uid').delete();
        file = File('${tempDir.path}/$uid');
      }

      var ref = await FirebaseStorage.instance
          .ref()
          .child(uid)
          .writeToFile(file)
          .future
          .catchError((e) {
        print(e.toString());
      });

      // var storage = await ref.writeToFile(file).future.catchError((e) {
      //   print(e.toString());
      // });
      return file;
    } else {
      return null;
    }
  }
}
