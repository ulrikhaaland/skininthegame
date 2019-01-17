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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSettingsPage extends StatefulWidget {
  ProfileSettingsPage({
    Key key,
    this.auth,
    this.onSignOut,
    this.user,
    this.setGroupPage,
    this.setBGSize,
    this.loading,
  }) : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback setGroupPage;
  final VoidCallback setBGSize;
  final User user;
  bool loading;

  @override
  ProfileSettingsPageState createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  File _image;

  Firestore firestoreInstace = Firestore.instance;

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
      body: new Stack(
        children: <Widget>[
          new Form(
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
          Essentials().loading(widget.loading)
        ],
      ),
    );
  }

  void postData() async {
    if (validateAndSave()) {
      widget.setBGSize();
      if (_image != null) {
        setState(() {
          widget.loading = true;
        });
        if (widget.user.profilePicURL != null) {
          await CachedNetworkImageProvider(
            widget.user.profilePicURL,
          ).evict().then<void>((bool success) {
            if (success) debugPrint('removed image!');
          });
        }

        widget.user.hasProfilePic =
            await ProfilePicture().uploadFile(widget.user.id, _image);
        var ref = await FirebaseStorage.instance
            .ref()
            .child(widget.user.id)
            .getDownloadURL();
        widget.user.profilePicURL = ref;
        QuerySnapshot qSnap = await firestoreInstace
            .collection("users/${widget.user.id}/groups")
            .getDocuments();
        qSnap.documents.forEach((DocumentSnapshot doc) {
          firestoreInstace
              .document("groups/${doc.documentID}/members/${widget.user.id}")
              .updateData({
            "profilepicurl": widget.user.profilePicURL,
          });
        });
        setState(() {
          widget.loading = false;
        });
      }
      Navigator.pop(context);
      await firestoreInstace.runTransaction((Transaction tx) async {
        await firestoreInstace.document("users/${widget.user.id}").updateData({
          'shareresults': widget.user.shareResults,
          'bio': widget.user.bio,
          "profilepicurl": widget.user.profilePicURL,
        });
      });
    }
  }

  Widget addImage() {
    if (_image != null) {
      return new CircleAvatar(
        radius: 35,
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
        backgroundImage: FileImage(_image),
        backgroundColor: Colors.grey[600],
      );
    }
    if (widget.user.profilePicURL == null) {
      return new CircleAvatar(
        radius: 35,
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 35,
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
        backgroundImage: CachedNetworkImageProvider(
          widget.user.profilePicURL,
        ),
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
