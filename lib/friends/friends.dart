import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/pages/group/group_page_one.dart';
import 'package:yadda/objects/user.dart';

class Friends extends StatefulWidget {
  const Friends(
      {Key key,
      this.auth,
      this.user,
      this.onSignOut,
      this.groupId,
      this.groupName})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final User user;
  final String groupId;
  final String groupName;

  @override
  FriendsState createState() => FriendsState();
}

class FriendsState extends State<Friends> {
  static final formKey = new GlobalKey<FormState>();

  final BaseAuth auth = Auth();

  bool userFound = false;
  String currentUserId;
  bool getStatus = false;

  String type;
  String groupId;

  List<String> data = new List<String>();
  String username;
  String email;
  String uid;
  String add;

  initState() {
    super.initState();
    currentUserId = widget.user.getId();
    groupId = widget.groupId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add to group"),
          actions: <Widget>[
            new FlatButton(
                child: new Text(
                  "Next",
                  style: new TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop()
                    ..push(MaterialPageRoute(
                        builder: (context) => GroupDashboard(
                              groupId: groupId,
                              user: widget.user,
                            )));
                }),
          ],
        ),
        body: friendSearch());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
              child: Container(
                  child: Row(
            children: <Widget>[
              new Icon(
                Icons.add,
                color: Colors.blue,
                size: 40.0,
              ),
              Text(
                document["brukernavn"],
                style: Theme.of(context).textTheme.headline,
              ),
            ],
          ))),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
        ],
      ),
      onTap: () {
        add = document.documentID;
        getUser();
        print(add);
      },
    );
  }

  void addToMap() {
    if (data.contains(uid)) {
      Firestore.instance.document("groups/$groupId/members/$uid").delete();
      data.remove(uid);
    } else {
      Firestore.instance
          .document("groups/$groupId/members/$uid")
          .setData({"uid": uid, "brukernavn": username});
      Firestore.instance
          .document("users/$uid/groups/$groupId")
          .setData({"name": widget.groupName, "groupid": groupId});
      data.add(uid);
    }
  }

  getUser() {
    Firestore.instance.document("users/$add").get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          username = datasnapshot.data["brukernavn"];
          email = datasnapshot.data["email"];
          uid = datasnapshot.data["uid"];
          print("$username, $email, $uid");
          addToMap();
        });
      }
    });
  }

  addToGroup() {
    Firestore.instance
        .document("groups/$groupId/members/$add")
        .setData({"uid": uid, 'name': username, "email": email});
  }

  List<Widget> row() {
    return [friendSearch()];
  }

  Widget friendSearch() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/$currentUserId/friends")
            .where("brukernavn", isGreaterThan: "0")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
