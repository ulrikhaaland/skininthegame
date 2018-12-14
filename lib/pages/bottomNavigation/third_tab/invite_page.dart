import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_page_one.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';

class UserPageInvites extends StatefulWidget {
  UserPageInvites({Key key, this.auth, this.user}) : super(key: key);
  final User user;
  final BaseAuth auth;

  @override
  UserPageInvitesState createState() => UserPageInvitesState();
}

enum FormType { edit, normal }

class UserPageInvitesState extends State<UserPageInvites> {
  String groupName;
  String groupId;
  String currentUserName;
  String currentUserId;
  String email;
  bool userFound = false;
  FormType _formType = FormType.normal;

  @override
  void initState() {
    super.initState();
    currentUserName = widget.user.userName;
    currentUserId = widget.user.id;
    userFound = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            iconEdit(),
          ],
          backgroundColor: UIData.darkest,
          title: new Text(
            "Invites",
            style: new TextStyle(fontSize: UIData.fontSize24),
          )),
      backgroundColor: UIData.dark,
      body: inviteStream(),
    );
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget iconEdit() {
    return new IconButton(
      icon: new Icon(Icons.edit),
      iconSize: 30.0,
      onPressed: () {
        if (_formType == FormType.normal) {
          setState(() {
            _formType = FormType.edit;
          });
        } else {
          setState(() {
            _formType = FormType.normal;
          });
        }
      },
    );
  }

  Widget _buildStream(BuildContext context, DocumentSnapshot document) {
    switch (_formType) {
      case FormType.normal:
        return new ListTile(
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            leading:
                new Icon(Icons.notifications, color: UIData.green, size: 40.0),
            title: Text(
                'You have recieved a new group invite from ${document.data["sendername"]} to join group "${document.data["groupname"]}".',
                style: new TextStyle(color: UIData.white),
                overflow: TextOverflow.clip),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GroupDashboard(
                        groupId: document.data["groupid"],
                        user: widget.user,
                      )));
            });
      case FormType.edit:
        return new ListTile(
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            leading:
                new Icon(Icons.notifications, color: UIData.green, size: 40.0),
            title: Text(
                'You have recieved a new group invite from ${document.data["sendername"]} to join group "${document.data["groupname"]}".',
                style: new TextStyle(color: UIData.white),
                overflow: TextOverflow.clip),
            trailing: new IconButton(
                icon: new Icon(
                  Icons.delete,
                  size: 40.0,
                  color: UIData.red,
                ),
                onPressed: () {
                  Firestore.instance
                      .document("users/$currentUserId/grouprequests/${document.documentID}")
                      .delete();
                }),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GroupDashboard(
                        groupId: document.data["groupid"],
                        user: widget.user,
                      )));
            });
    }
  }

  Widget inviteStream() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/$currentUserId/grouprequests")
            .orderBy("finaldateaandtime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildStream(context, snapshot.data.documents[index]),
          );
        });
  }
}
