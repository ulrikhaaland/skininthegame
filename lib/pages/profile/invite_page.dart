import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_page_one.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/utils/essentials.dart';

class UserPageInvites extends StatefulWidget {
  UserPageInvites({Key key, this.auth, this.user}) : super(key: key);
  final User user;
  final BaseAuth auth;

  @override
  UserPageInvitesState createState() => UserPageInvitesState();
}

class UserPageInvitesState extends State<UserPageInvites> {
  String groupName;
  String groupId;
  String currentUserName;
  String currentUserId;
  String email;
  bool userFound = false;

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
          backgroundColor: UIData.appBarColor,
          title: new Text(
            "Invites",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          )),
      backgroundColor: UIData.dark,
      body: inviteStream(),
    );
  }

  Widget _buildStream(BuildContext context, DocumentSnapshot document) {
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            leading:
                new Icon(Icons.notifications, color: UIData.green, size: 40.0),
            title: Text(
                'You have recieved a new group invite from ${document.data["sendername"]} to join group "${document.data["groupname"]}".',
                style: new TextStyle(color: UIData.blackOrWhite),
                overflow: TextOverflow.clip),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GroupDashboard(
                        groupId: document.data["groupid"],
                        user: widget.user,
                      )));
            }),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Delete',
          color: UIData.red,
          icon: Icons.delete,
          onTap: () => Firestore.instance
              .document(
                  "users/$currentUserId/grouprequests/${document.documentID}")
              .delete(),
        ),
      ],
    );
  }

  Widget inviteStream() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/$currentUserId/grouprequests")
            .orderBy("finaldateaandtime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Essentials().loading(true);
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildStream(context, snapshot.data.documents[index]),
          );
        });
  }
}
