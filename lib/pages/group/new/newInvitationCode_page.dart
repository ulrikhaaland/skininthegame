import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/essentials.dart';

class InvitationCodePage extends StatefulWidget {
  InvitationCodePage({
    Key key,
    this.newGroupOption,
    this.user,
    this.group,
    this.initState,
    this.onUpdate,
  }) : super(key: key);
  final VoidCallback initState;
  final VoidCallback onUpdate;

  final User user;
  final Group group;
  final bool newGroupOption;

  @override
  InvitationCodePageState createState() => InvitationCodePageState();
}

enum FormType { public, private }

class InvitationCodePageState extends State<InvitationCodePage> {
  static final formKey = new GlobalKey<FormState>();

  String currentUserId;
  String currentUserName;

  String groupId;
  String groupName;
  bool loading = false;

  String reusableGroupCode = "";
  String oneTimeGroupCode = "";
  String adminGroupCode = "";

  String currentReusableGroupCode = "";
  String currentOneTimeGroupCode = "";
  String currentAdminGroupCode = "";

  final Firestore fireStoreInstance = Firestore.instance;

  initState() {
    super.initState();
    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    groupId = widget.group.id;
    _getGroupCode();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: new AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          actions: <Widget>[
            // IconButton(
            //     padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
            //     icon: new Icon(Icons.home,
            //         color: Colors.white, size: UIData.iconSizeAppBar),
            //     onPressed: () {
            //       Navigator.of(context)..pop()..pop();
            //     }),
          ],
          backgroundColor: UIData.appBarColor,
          title: new Text(
            "Invitation Codes",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          ),
        ),
        backgroundColor: UIData.dark,
        body: new Form(
          key: formKey,
          child: Essentials().setScreen(_newGame(), loading),
        ));
  }

  Widget _newGame() {
    return new SingleChildScrollView(
        child: new Container(
            child: new Column(children: [
      new Container(
          child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        new Container(
            padding: const EdgeInsets.all(16.0),
            child: new Form(child: new Column(children: _pageWidgets()))),
      ])),
    ])));
  }

  void copied() {
    Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
      backgroundColor: UIData.yellow,
      content: new Text(
        "Copied!",
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black),
      ),
    ));
  }

  List<Widget> _pageWidgets() {
    return [
      new ListTile(
        leading: new Text(
          "REUSABLE CODE",
          style: new TextStyle(
            color: UIData.blackOrWhite,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      new ListTile(
        trailing: new FlatButton(
            child: new Text(
              "Copy",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
            ),
            onPressed: () {
              Clipboard.setData(
                  new ClipboardData(text: currentReusableGroupCode));
              copied();
            }),
        contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 20.0, 0.0),
        leading: new IconButton(
          iconSize: 40.0,
          icon: Icon(
            Icons.refresh,
            color: UIData.yellow,
          ),
          onPressed: () {
            _setGroupCode(reusableGroupCode, "reusablegroupcode",
                currentReusableGroupCode);
          },
        ),
        title: new TextFormField(
          keyboardAppearance: Brightness.dark,
          style: new TextStyle(color: UIData.blackOrWhite),
          key: new Key('multicode'),
          decoration: new InputDecoration(
              border: OutlineInputBorder(),
              hintText: currentReusableGroupCode,
              hintStyle: new TextStyle(color: UIData.blackOrWhite),
              labelStyle: new TextStyle(color: Colors.grey[600])),
          autocorrect: false,
        ),
      ),
      new Container(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
          child: new Text(
              "Anyone who has this code will be able to join your group. You can refresh to delete the current code and get a new one.",
              key: new Key('multicodehint'),
              style: new TextStyle(
                  fontSize: UIData.fontSize12, color: Colors.grey[600]),
              textAlign: TextAlign.center)),
      new Divider(
        height: 0.0,
        color: Colors.black,
      ),
      new ListTile(
        leading: new Text(
          "ONE TIME CODE",
          style: new TextStyle(
            color: UIData.blackOrWhite,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      new ListTile(
        trailing: new FlatButton(
            child: new Text(
              "Copy",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
            ),
            onPressed: () {
              Clipboard.setData(
                  new ClipboardData(text: currentOneTimeGroupCode));
              copied();
            }),
        contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 20.0, 0.0),
        leading: new IconButton(
          iconSize: 40.0,
          icon: Icon(
            Icons.refresh,
            color: UIData.yellow,
          ),
          onPressed: () {
            _setGroupCode(
                oneTimeGroupCode, "onetimegroupcode", currentOneTimeGroupCode);
          },
        ),
        title: new TextFormField(
          keyboardAppearance: Brightness.dark,
          style: new TextStyle(color: UIData.blackOrWhite),
          key: new Key('onetimecode'),
          decoration: new InputDecoration(
              border: OutlineInputBorder(),
              hintText: currentOneTimeGroupCode,
              hintStyle: new TextStyle(color: UIData.blackOrWhite),
              labelStyle: new TextStyle(color: Colors.grey[600])),
          autocorrect: false,
        ),
      ),
      new Container(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
          child: new Text(
              "This code can only be used once, you can refresh to get multiple one time codes.",
              key: new Key('onetimecodehint'),
              style: new TextStyle(
                  fontSize: UIData.fontSize12, color: Colors.grey[600]),
              textAlign: TextAlign.center)),
      new Divider(
        height: 0.0,
        color: Colors.black,
      ),
      new ListTile(
        leading: new Text(
          "ADMIN CODE",
          style: new TextStyle(
            color: UIData.blackOrWhite,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      new ListTile(
        trailing: new FlatButton(
            child: new Text(
              "Copy",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
            ),
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: currentAdminGroupCode));
              copied();
            }),
        contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 20.0, 0.0),
        leading: new IconButton(
          iconSize: 40.0,
          icon: Icon(
            Icons.refresh,
            color: UIData.yellow,
          ),
          onPressed: () => _setGroupCode(
              adminGroupCode, "admingroupcode", currentAdminGroupCode),
        ),
        title: new TextFormField(
          keyboardAppearance: Brightness.dark,
          style: new TextStyle(color: UIData.blackOrWhite),
          key: new Key('admincode'),
          decoration: new InputDecoration(
              border: OutlineInputBorder(),
              hintText: currentAdminGroupCode,
              hintStyle: new TextStyle(color: UIData.blackOrWhite),
              labelStyle: new TextStyle(color: Colors.grey[600])),
          autocorrect: false,
        ),
      ),
      new Container(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
          child: new Text(
              "Anyone who has this code will be able to join your group as an admin. You can refresh to delete the current code and get a new one.",
              key: new Key('admincodehint'),
              style: new TextStyle(
                  fontSize: UIData.fontSize12, color: Colors.grey[600]),
              textAlign: TextAlign.center)),
    ];
  }

  _getGroupCode() async {
    fireStoreInstance
        .document("groups/$groupId/codes/admingroupcode")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        currentAdminGroupCode = datasnapshot.data["code"];
        setState(() {});
      }
    });

    fireStoreInstance
        .document("groups/$groupId/codes/reusablegroupcode")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        currentReusableGroupCode = datasnapshot.data["code"];
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void _setGroupCode(String code, String typeOfCode, String currentCode) {
    try {
      var random = new Random().nextInt(999999999);
      code = random.toString();

      if (typeOfCode == "reusablegroupcode") {
        code = code + "r";
        currentReusableGroupCode = code;
      } else if (typeOfCode == "onetimegroupcode") {
        code = code + "o";
        currentOneTimeGroupCode = code;
      } else if (typeOfCode == "admingroupcode") {
        code = code + "a";
        currentAdminGroupCode = code;
      }
      _checkGroupCode(code, typeOfCode, currentCode);
    } catch (e) {
      setState(() {
        print(e);
      });
      print(e);
    }
  }

  _checkGroupCode(String code, String typeOfCode, String currentCode) {
    fireStoreInstance
        .collection("codes")
        .where("code", isEqualTo: code)
        .getDocuments()
        .then((datasnapshot) {
      if (datasnapshot.documents.isEmpty) {
        setState(() {
          if (typeOfCode == "onetimegroupcode") {
            fireStoreInstance
                .document("groups/$groupId/codes/$typeOfCode/codes/$code")
                .setData({
              "code": code,
            });
            fireStoreInstance.document("codes/$code").setData({
              "code": code,
              "groupid": widget.group.id,
              "groupname": widget.group.name,
            });
          } else {
            fireStoreInstance.document("codes/$groupId").updateData({
              "$typeOfCode": code,
            });

            fireStoreInstance
                .document("groups/$groupId/codes/$typeOfCode")
                .setData({
              "code": code,
            });
            // fireStoreInstance.document("codes/$code").setData({
            //   "code": code,
            //   "groupid": widget.groupId,
            //   "groupname": widget.groupName,
            // });
          }
        });
      } else {
        _setGroupCode(code, typeOfCode, currentCode);
      }
    });
  }
}
