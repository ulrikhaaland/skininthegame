import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/utils/ProfilePic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/pages/legal/TermsAndConditions.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/utils/delete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yadda/pages/legal/my_data.dart';

class ProfileSettingsPage extends StatefulWidget {
  ProfileSettingsPage({
    Key key,
    this.user,
    this.setGroupPage,
    this.setBGSize,
    this.signOut,
    this.loading,
  }) : super(key: key);
  final VoidCallback setGroupPage;
  final VoidCallback setBGSize;
  final VoidCallback signOut;
  final User user;
  bool loading;

  @override
  ProfileSettingsPageState createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  File _image;

  Firestore firestoreInstance = Firestore.instance;

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
    _image = widget.user.image;
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
      body: new SingleChildScrollView(
        child: new Stack(
          children: <Widget>[
            new Form(
                key: formKey,
                child: new Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                  ),
                  new Row(
                    children: <Widget>[
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
                      deleteImage(),
                    ],
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
                          widget.user.bio = val.trim();
                        },
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 16),
                  // ),
                  Layout().dividerPadded(),
                  Padding(
                    padding: EdgeInsets.only(top: 70),
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
                  Layout().dividerPadded(),
                  new ListTile(
                    title: new Text(
                      "Currency",
                      style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize20,
                      ),
                    ),
                    trailing: Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: UIData.appBarColor),
                      child: new Container(
                          // color: UIData.appBarColor,
                          child: new DropdownButton<String>(
                        style: TextStyle(color: UIData.blackOrWhite),
                        hint: new Text(
                          widget.user.currency,
                          style: new TextStyle(
                              color: UIData.blackOrWhite,
                              fontWeight: FontWeight.bold),
                        ),
                        items: <String>['USD', 'EURO', 'NOK', 'GBP']
                            .map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(
                              value,
                              style: new TextStyle(color: UIData.blackOrWhite),
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {
                          if (widget.user.currency != _) {
                            setState(() {
                              widget.user.currency = _;
                            });
                          }
                        },
                      )),
                    ),
                    onTap: null,
                  ),
                  Layout().dividerPadded(),
                  Padding(
                    padding: EdgeInsets.only(top: 70),
                  ),
                  new ListTile(
                    title: new Text(
                      "Policies & Agreements",
                      style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize20,
                      ),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditions())),
                  ),
                  Layout().dividerPadded(),
                  new ListTile(
                    title: new Text(
                      "My Data",
                      style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize20,
                      ),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyData(user: widget.user,))),
                  ),
                  Layout().dividerPadded(),
                  new ListTile(
                    title: new Text(
                      "Log Out",
                      style: new TextStyle(
                        color: UIData.red,
                        fontSize: UIData.fontSize20,
                      ),
                    ),
                    onTap: () => signOut(),
                  ),
                  Layout().dividerPadded(),
                  new ListTile(
                    title: new Text(
                      "Delete Profile",
                      style: new TextStyle(
                        color: UIData.red,
                        fontSize: UIData.fontSize20,
                      ),
                    ),
                    onTap: () {
                      AlertDialog alertDialog = new AlertDialog(
                        backgroundColor: UIData.dark,
                        content: new Container(
                          height: 180,
                          child: Column(
                            children: <Widget>[
                              new Text(
                                "All your data will be deleted and your profile can not be restored.",
                                style: TextStyle(color: UIData.blackOrWhite),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 32),
                              ),
                              new PrimaryButton(
                                color: UIData.red,
                                onPressed: () async {
                                  await Delete().deleteUser(widget.user.id);
                                  var user =
                                      await FirebaseAuth.instance.currentUser();
                                  user.delete();
                                  signOut();
                                },
                                text: "Delete Profile",
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12),
                              ),
                              new FlatButton(
                                child: new Text(
                                  "Cancel",
                                  style: TextStyle(color: UIData.blue),
                                ),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          ),
                        ),
                      );
                      showDialog(context: context, child: alertDialog);
                    },
                  ),
                  Layout().dividerPadded(),
                  Padding(
                    padding: EdgeInsets.only(top: 32),
                  ),
                ])),
            Essentials().loading(widget.loading)
          ],
        ),
      ),
    );
  }

  signOut() {
    Navigator.of(context)..pop()..pop()..pop();
    widget.signOut();
  }

  Widget deleteImage() {
    if (widget.user.profilePicURL != null) {
      return new FlatButton(
        color: UIData.dark,
        child: new Text(
          "Delete picture",
          style: new TextStyle(color: UIData.blackOrWhite),
        ),
        onPressed: () {
          setState(() {
            ProfilePicture().deleteFile(widget.user.id);
            firestoreInstance.document("users/${widget.user.id}").updateData({
              "profilepicurl": null,
            });
            _image = null;
            widget.user.profilePicURL = null;
            widget.user.image = null;
          });
        },
      );
    } else {
      return Container();
    }
  }

  void postData() async {
    if (validateAndSave()) {
      widget.setBGSize();

      if (_image != null) {
        widget.user.image = _image;
        // new Timer(Duration(seconds: 10), () => widget.user.image = null);
      }

      Navigator.pop(context);
      if (_image != null) {
        if (widget.user.profilePicURL != null) {
          await CachedNetworkImageProvider(
            widget.user.profilePicURL,
          ).evict().then<void>((bool success) {
            if (success) debugPrint('removed image!');
          });
        }

        widget.user.hasProfilePic =
            await ProfilePicture().uploadFile(widget.user.id, _image);
        var ref = await ProfilePicture().getDownloadUrl(widget.user.id);
        widget.user.profilePicURL = ref;
        QuerySnapshot qSnap = await firestoreInstance
            .collection("users/${widget.user.id}/groups")
            .getDocuments();
        qSnap.documents.forEach((DocumentSnapshot doc) {
          firestoreInstance
              .document("groups/${doc.documentID}/members/${widget.user.id}")
              .updateData({
            "profilepicurl": ref,
          });
        });
        updateData();
      }
      updateData();
    }
  }

  void updateData() async {
    await firestoreInstance.document("users/${widget.user.id}").updateData({
      'shareresults': widget.user.shareResults,
      'bio': widget.user.bio,
      "profilepicurl": widget.user.profilePicURL,
      'currency': widget.user.currency,
    });
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
    } else if (widget.user.profilePicURL == null) {
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
