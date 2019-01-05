import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/pages/profile/profile_page.dart';

class ProfilePageAlt extends StatefulWidget {
  ProfilePageAlt({
    Key key,
    this.group,
    this.profileUserName,
    this.userEmail,
    this.profileUserId,
    this.profileUserIsAdmin,
    this.user,
  }) : super(key: key);
  final Group group;
  final String profileUserName;
  final String userEmail;
  final String profileUserId;
  final User user;
  final bool profileUserIsAdmin;

  @override
  ProfilePageAltState createState() => ProfilePageAltState();
}

class ProfilePageAltState extends State<ProfilePageAlt> {
  String groupName;
  String groupId;
  String currentUserId;
  String userName;
  String email;

  String profileUserIsAdmin;

  bool userFound = false;
  bool profileIsAdmin;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.user.id;
    profileIsAdmin = widget.profileUserIsAdmin;
    checkIfAdmin();
  }

  checkIfAdmin() {
    Firestore.instance
        .document(
            "groups/${widget.group.id}/members/${widget.profileUserId}")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        profileIsAdmin = datasnapshot.data["admin"];
        userFound = true;
        setScreen();
        if (profileIsAdmin == true) {
          setState(() {
            profileUserIsAdmin = "Remove as admin";
            profileIsAdmin = false;
          });
        } else if (profileIsAdmin != true) {
          setState(() {
            profileUserIsAdmin = "Make this user admin";
            profileIsAdmin = true;
          });
        }
      }
    });
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  setScreen() {
    if (userFound == false) {
      return loading();
    } else {
      return page();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                icon: new Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.of(context)..pop()..pop();
                }),
          ],
          backgroundColor: UIData.darkest,
          title: new Text(
            "Settings",
            style: new TextStyle(fontSize: UIData.fontSize24),
          )),
      backgroundColor: UIData.dark,
      body: setScreen(),
    );
  }

  Widget page() {
    return ListView(
      children: <Widget>[
        new ListTile(
          leading: new Icon(
            Icons.person,
            size: 40.0,
            color: Colors.blue,
          ),
          title: new Text(
            "${widget.profileUserName}",
            style:
                new TextStyle(fontSize: UIData.fontSize20, color: UIData.white),
          ),
          onTap: () =>  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(
                      user: widget.user,
                      profileId: widget.profileUserId,
                    )),
          ),
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        ),
        new ListTile(
          leading: new Icon(
            Icons.vpn_key,
            size: 40.0,
            color: Colors.yellow[700],
          ),
          title: new Text(
            "$profileUserIsAdmin",
            style:
                new TextStyle(color: UIData.white, fontSize: UIData.fontSize20),
          ),
          onTap: () {
            Firestore.instance
                .document(
                    "groups/${widget.group.id}/members/${widget.profileUserId}")
                .updateData({
              "admin": profileIsAdmin,
            });
            checkIfAdmin();
          },
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
          leading: new Icon(
            Icons.exit_to_app,
            size: 40.0,
            color: UIData.red,
          ),
          title: new Text(
            "Remove from group",
            style:
                new TextStyle(color: UIData.white, fontSize: UIData.fontSize20),
          ),
          onTap: () {
            Firestore.instance
                .document(
                    "groups/${widget.group.id}/members/${widget.profileUserId}")
                .delete();
            Firestore.instance
                .document(
                    "users/${widget.profileUserId}/groups/${widget.group.id}")
                .delete();
            Navigator.pop(context);
          },
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
