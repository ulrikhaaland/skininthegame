import 'package:firebase_storage/firebase_storage.dart';
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
    await ref.putFile(file).onComplete;
    return true;
  }

  Future<String> getDownloadUrl(String uid) async {
    String ref;
    try {
      ref = await FirebaseStorage.instance.ref().child(uid).getDownloadURL();
    } catch (e) {
      print(e);
    }

    print(ref);
    return ref;
  }

  Future<Null> deleteFile(String fileName) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.delete();
  }
}
