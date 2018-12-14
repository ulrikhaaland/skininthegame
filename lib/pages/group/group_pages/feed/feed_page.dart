import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import '../../new/new_post_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';

class FeedPage extends StatefulWidget {
  FeedPage({Key key, this.user, this.group}) : super(key: key);
  final User user;
  final Group group;

  @override
  FeedPageState createState() => FeedPageState();
}

enum FormType { normal, edit }

class FeedPageState extends State<FeedPage> {
  FormType _formType = FormType.normal;

  String groupName;
  String groupId;
  String currentUserId;
  String currentUserName;
  String email;
  bool userFound = false;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
          backgroundColor: UIData.appBarColor,
          actions: <Widget>[
            iconEdit(),
            iconAdd(),
          ],
          centerTitle: true,
          title: new Text(
            "Posts",
            style: new TextStyle(
              fontSize: UIData.fontSize24,
              color: UIData.blackOrWhite,
            ),
          )),
      backgroundColor: UIData.dark,
      body: streamOfPosts(),
    );
  }

  Widget iconAdd() {
    if (widget.group.admin == true) {
      return new IconButton(
        icon: new Icon(Icons.add_circle_outline),
        iconSize: UIData.iconSizeAppBar,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPostPage(widget.user, widget.group,
                      "groups/${widget.group.id}/posts", false, false)));
        },
      );
    } else {
      return new Text("");
    }
  }

  Widget iconEdit() {
    if (widget.group.admin == true) {
      return new IconButton(
        icon: new Icon(Icons.edit),
        iconSize: UIData.iconSizeAppBar,
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
    } else {
      return new Text("");
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    switch (_formType) {
      case FormType.normal:
        return new ListTile(
          dense: true,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["name"]} ",
                style: new TextStyle(color: UIData.blue, fontSize: 20.0),
                overflow: TextOverflow.ellipsis,
              ),
              new Text(
                "${document.data["dayofweek"]} ${document.data["time"]} ${document.data["date"]}",
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(color: Colors.grey[600]),

              )
            ],
          ),
          contentPadding: EdgeInsets.all(10.0),
          subtitle: new Text(
            "${document.data["body"]}",
            // overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
                letterSpacing: .50),
          ),
        );

      case FormType.edit:
        return new ListTile(
          trailing: new IconButton(
              icon: new Icon(
                Icons.delete,
                size: 40.0,
                color: UIData.red,
              ),
              onPressed: () {
                Firestore.instance
                    .document(
                        "groups/${widget.group.id}/posts/${document.documentID}")
                    .delete();
              }),
          dense: true,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["name"]}",
                style: new TextStyle(color: UIData.blue, fontSize: 20.0),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(10.0),
          subtitle: new Text(
            "${document.data["body"]}",
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
                letterSpacing: .50),
          ),
        );
    }
  }

  Widget streamOfPosts() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("groups/${widget.group.id}/posts")
            .orderBy("orderbytime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return loading();
          else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }
        });
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
