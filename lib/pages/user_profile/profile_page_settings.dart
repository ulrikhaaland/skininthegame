import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/utils/ProfilePic.dart';

import 'package:firebase_storage/firebase_storage.dart';

class ProfileSettingsPage extends StatefulWidget {
  ProfileSettingsPage({
    Key key,
    this.auth,
    this.onSignOut,
    this.user,
    this.setGroupPage,
    this.setBGSize,
  }) : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback setGroupPage;
  final VoidCallback setBGSize;
  final User user;

  @override
  ProfileSettingsPageState createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  File _image;

  String profilePicURL;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  bool userFound = false;

  @override
  void initState() {
    super.initState();
    userFound = true;
  }

  void loadImage() async {
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(widget.user.id);
    var downloadUrl = await storageRef.getDownloadURL();
    profilePicURL = downloadUrl.toString();
    setState(() {
      userFound = true;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (userFound == true) {
      return Scaffold(
        backgroundColor: UIData.dark,
        appBar: AppBar(
          backgroundColor: UIData.appBarColor,
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Text(
            "Edit Profile",
            style: TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
          ),
          actions: <Widget>[
            new FlatButton(
                child: new Text(
                  "Update",
                  style: new TextStyle(
                      fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
                  textAlign: TextAlign.center,
                ),
                onPressed: () => postData()),
          ],
        ),
        body: new Form(
            key: formKey,
            child: new Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16),
              ),
              new Align(
                alignment: Alignment.centerLeft,
                child: new Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: GestureDetector(
                    onTap: () => getImage(),
                    child: addImage(),
                  ),
                ),
              ),
              new Container(
                // color: UIData.darkest,
                child: ListTile(
                  // leading: new Text(
                  //   "Biography \n",
                  //   style: TextStyle(color: UIData.blackOrWhite, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  // ),
                  title: new TextFormField(
                    style: TextStyle(color: UIData.blackOrWhite),
                    initialValue: "${widget.user.bio}",
                    maxLines: 2,
                    maxLength: 160,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // UnderlineInputBorder(
                        //     borderSide: BorderSide(color: UIData.blackOrWhite)),
                        labelText: "Add a biography to your profile",
                        labelStyle: TextStyle(color: Colors.grey[600])),
                    onSaved: (val) {
                      if (val.isEmpty) {
                        val = "";
                      }
                      widget.user.bio = val;
                    },
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 16),
              // ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Divider(
                  height: 0.1,
                  color: Colors.black,
                ),
              ),
              new ListTile(
                title: new Text(
                  "Share Results",
                  style: new TextStyle(
                    color: UIData.blackOrWhite,
                    fontSize: UIData.fontSize20,
                  ),
                ),
                trailing: new Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  activeColor: UIData.green,
                  value: widget.user.shareResults,
                  onChanged: (bool val) {
                    setState(() {
                      widget.user.shareResults = val;
                    });
                  },
                ),
                onTap: null,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Divider(
                  height: 0.1,
                  color: Colors.black,
                ),
              ),
            ])),
      );
    } else {
      return Essentials();
    }
  }

  void postData() async {
    if (validateAndSave()) {
      widget.setBGSize();
      if (_image != null) {
        widget.user.profilePic = _image;
        ProfilePicture().uploadFile(widget.user.id, widget.user.profilePic);
      }
      Navigator.pop(context);
      await Firestore.instance.runTransaction((Transaction tx) async {
        await Firestore.instance
            .document("users/${widget.user.id}")
            .updateData({
          'shareresults': widget.user.shareResults,
          'bio': widget.user.bio,
        });
      });
    }
  }

  Widget addImage() {
    if (widget.user.profilePic == null) {
      return new CircleAvatar(
        radius: 40,
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.grey[600],
      );
    } else {
      File file;
      if (_image == null) {
        file = widget.user.profilePic;
      } else {
        file = _image;
      }
      return new CircleAvatar(
        radius: 40,
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
        backgroundImage: FileImage(file),
        backgroundColor: Colors.grey[600],
      );
    }
  }

  Future<Null> uploadFile() async {
    final String fileName = "${widget.user.id}";
    final File file = _image;

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    ref.putFile(file);
  }
}
