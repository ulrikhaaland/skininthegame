import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_page_one.dart';
import 'dart:math';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';
import 'package:yadda/pages/inAppPurchase/subLevel.dart';
import 'package:yadda/utils/layout.dart';

class NewGroup extends StatefulWidget {
  NewGroup({Key key, this.user, this.onUpdate}) : super(key: key);
  final User user;
  final VoidCallback onUpdate;

  @override
  NewGroupState createState() => NewGroupState();
}

enum FormType { public, private }

class NewGroupState extends State<NewGroup> {
  static final formKey = new GlobalKey<FormState>();
  Group group;
  bool isLoading = false;

  String currentUserId;

  // New game
  String groupName = "unnamed";
  String _groupInfo = "";
  String groupType = "public";
  String dailyMessage = "";
  String currentUserName;

  String groupId;
  String publicPrivateText =
      "Public groups can be found in search, anyone can see and join them.";

  bool gameIdAvailable = false;
  bool userFound = false;
  bool public = true;

  IconData privateIcon;
  IconData publicIcon = Icons.check;
  Color privateIconColor;
  Color publicIconColor;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: UIData.dark,
      appBar: new AppBar(
        // elevation: 0,
        backgroundColor: UIData.appBarColor,
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
        actions: <Widget>[
          new FlatButton(
              child: new Text(
                "Create",
                style: new TextStyle(
                    fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                if (await SubLevel()
                    .groupsLeft(widget.user.id, widget.user.subLevel)) {
                  setState(() {
                    isLoading = true;
                  });
                  setGroupId();
                } else {
                  int i;
                  widget.user.subLevel == 0 ? i = 3 : i = 10;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Subscription(
                                user: widget.user,
                                info: true,
                                title:
                                    "Your current subscription does only allow you to be a part of $i groups at any given time",
                              )));
                }
              }),
        ],
        title: new Text(
          "New Group",
          style: new TextStyle(
              fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
        ),
      ),
      body: new Stack(
        children: <Widget>[
          page(),
          Essentials().loading(isLoading),
        ],
      ),
    );
  }

  initState() {
    super.initState();
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void setGroupId() {
    try {
      var random = new Random().nextInt(99999);
      groupId = random.toString();
      checkGroupId();
      print(groupId);
    } catch (e) {
      setState(() {
        print(e);
      });
      print(e);
    }
  }

  void checkGroupId() async {
    DocumentReference cRef = Firestore.instance.document("groups/$groupId");

    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot qSnap = await cRef.get();
      if (!qSnap.exists) {
        setState(() {
          debugPrint("true");
          gameIdAvailable = true;
          _saveGroup();
        });
      } else {
        setState(() {
          debugPrint("false");
          gameIdAvailable = false;
          setGroupId();
        });
      }
    });
  }

  void _saveGroup() {
    group = new Group(groupName, dailyMessage, currentUserId, groupId,
        _groupInfo, groupName.toLowerCase(), 1, public, 0, true, 0, 0, true);
    group.pushGroupToFirestore("groups/$groupId");
    group.pushGroupToFirestore("users/$currentUserId/groups/$groupId");
    Firestore.instance
        .document("groups/$groupId/members/$currentUserId")
        .setData({
      "uid": widget.user.id,
      'username': widget.user.userName,
      "admin": true,
      "notification": true,
      "fcm": widget.user.fcm,
      "profilepicurl": widget.user.profilePicURL,
    });
    Firestore.instance.document("codes/$groupId").setData({
      "groupid": groupId,
      "groupname": groupName,
      "reusablegroupcode": "",
      "admingroupcode": "",
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context)
      ..pop()
      ..push(MaterialPageRoute(
          builder: (context) => GroupDashboard(
                groupId: groupId,
                user: widget.user,
                group: group,
                onUpdate: () => widget.onUpdate(),
              )));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
      child: child,
    );
  }

  Widget paddedTwo({Widget child}) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: child,
    );
  }

  Widget page() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
        ),
        padded(
            child: new TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          style: new TextStyle(color: UIData.blackOrWhite),
          key: new Key('Name'),
          decoration: new InputDecoration(
              labelText: 'Name',
              labelStyle: new TextStyle(color: Colors.grey[600])),
          autocorrect: false,
          onChanged: (String str) {
            setState(() {
              groupName = str;
            });
          },
        )),
        padded(
            child: new TextField(
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          style: new TextStyle(color: UIData.blackOrWhite),
          key: new Key('info'),
          decoration: new InputDecoration(
              labelText: 'Additional information',
              labelStyle: new TextStyle(color: Colors.grey[600])),
          maxLines: 3,
          autocorrect: false,
          onChanged: (String str) {
            setState(() {
              _groupInfo = str;
            });
          },
        )),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
        ),
        padded(
          child: new Text(
              "You can provide an optional description for your group.",
              key: new Key('hint'),
              style: new TextStyle(fontSize: UIData.fontSize12, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 38.0, 0.0, 0.0),
        ),
        padded(
          child: new Text(
            "Group type",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
        ),
        new Padding(
          padding: EdgeInsets.only(left: 18.0, right: 18.0),
          child: 
         Layout().divider(),),
        new ListTile(
            leading: new Icon(
              publicIcon,
              color: Colors.green,
              size: 40.0,
            ),
            title: new Text(
              "Public",
              style: new TextStyle(color: UIData.blackOrWhite, fontSize: 18.0),
            ),
            onTap: () {
              setState(() {
                publicIcon = Icons.check;
                privateIcon = null;
                publicPrivateText =
                    "Public groups can be found in search, anyone can see and join them.";
                public = true;
                groupType = "public";
              });
            }),
        new Padding(
          padding: EdgeInsets.only(left: 18.0, right: 18.0),
          child: 
         Layout().divider(),),
        new ListTile(
            leading: new Icon(privateIcon, size: 40.0, color: UIData.green),
            title: new Text(
              "Private",
              style: new TextStyle(color: UIData.blackOrWhite, fontSize: 18.0),
            ),
            onTap: () {
              setState(() {
                publicIcon = null;
                privateIcon = Icons.check;
                publicPrivateText =
                    "Private groups can only be joined via an invite.";
                public = false;
                groupType = "private";
              });
            }),
        new Padding(
          padding: EdgeInsets.only(left: 18.0, right: 18.0),
          child: 
         Layout().divider(),),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        ),
        padded(
            child: new Text(publicPrivateText,
                key: new Key('hint'),
                style: new TextStyle(fontSize: UIData.fontSize12, color: Colors.grey[600]),
                textAlign: TextAlign.center)),
        paddedTwo(),
      ],
    );
  }
}
