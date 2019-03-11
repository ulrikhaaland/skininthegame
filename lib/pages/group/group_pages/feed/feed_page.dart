import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import '../../new/new_post_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/widgets/report_dialog.dart';

class FeedPage extends StatefulWidget {
  FeedPage({Key key, this.user, this.group}) : super(key: key);
  final User user;
  final Group group;

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
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
    if (widget.group.admin) {
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Slidable(
      enabled: widget.group.admin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
          child: new ListTile(
        dense: true,
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(
              "${document.data["name"]} ",
              style: new TextStyle(color: UIData.blue, fontSize: 20.0),
              overflow: TextOverflow.ellipsis,
            ),
            new Row(
              children: <Widget>[
                new Text(
                  "${document.data["dayofweek"]} ${document.data["time"]} ${document.data["date"]}",
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(color: Colors.grey[600]),
                ),
                this.reportButton(document),
              ],
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
      )),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Delete',
          color: UIData.red,
          icon: Icons.delete,
          onTap: () => Firestore.instance
              .document(
                  "groups/${widget.group.id}/posts/${document.documentID}")
              .delete(),
        ),
      ],
    );
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

  Widget reportButton(DocumentSnapshot document) {
    if (widget.group.admin) {
      return new Container();
    } else {
      return new IconButton(
        icon: Icon(
          Icons.more_vert,
          color: UIData.blackOrWhite,
        ),
        onPressed: () {
          ReportDialog reportDialog = new ReportDialog(
            reportedById: widget.user.id,
            reportedId: widget.group.id,
            type: "post",
            text: "Report post",
            postId: document.documentID,
          );
          showDialog(context: context, child: reportDialog);
        },
      );
    }
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
