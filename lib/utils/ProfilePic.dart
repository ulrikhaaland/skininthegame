import 'package:flutter/services.dart' show rootBundle;

import 'package:firebase_storage/firebase_storage.dart';

import 'dart:math';

import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

class ProfilePicture {
  Future<bool> uploadFile(String fileName, File file) async {
    // final ByteData bytes = await rootBundle.load(filepath);
    // final Directory tempDir = Directory.systemTemp;
    // final String fileName = "${Random().nextInt(10000)}.jpg";
    // final File file = File('${tempDir.path}/$fileName');
    // file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    var task = await ref.putFile(file).onComplete;
    return true;
  }

  Future<String> getDownloadUrl(String uid) async {
     var ref = FirebaseStorage.instance.ref().child(uid).getDownloadURL();
      return ref;
  }
}
