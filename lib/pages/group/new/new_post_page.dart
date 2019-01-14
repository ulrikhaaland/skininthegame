import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/utils/post.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';

class NewPostPage extends StatefulWidget {
  NewPostPage(
      this.user, this.group, this.routePath, this.logPost, this.fromGame);
  final User user;
  final Group group;
  final String routePath;
  final bool fromGame;
  final bool logPost;
  @override
  NewPostPageState createState() => NewPostPageState();
}

class NewPostPageState extends State<NewPostPage> {
  String postBody = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: UIData.dark,
        appBar: new AppBar(
            backgroundColor: UIData.appBarColor,
            iconTheme: IconThemeData(color: UIData.blackOrWhite),
            actions: <Widget>[
              new FlatButton(
                  child: new Text(
                    "Create",
                    style: new TextStyle(
                        fontSize: UIData.fontSize16,
                        color: UIData.blackOrWhite),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () =>
                      postMessage(widget.logPost, widget.routePath)),
            ],
            title: new Text(
              "New Post",
              style: new TextStyle(
                  fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
            )),
        body: new ListView(
          children: <Widget>[
            new Container(
              child: new Form(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
                  child: new TextField(
                      maxLines: 5,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: new TextStyle(color: UIData.blackOrWhite),
                      decoration: new InputDecoration(
                          labelText: 'Text',
                          labelStyle:
                              new TextStyle(color: UIData.blackOrWhite)),
                      autocorrect: false,
                      onChanged: (String str) => postBody = str),
                ),
              ),
            ),
          ],
        ));
  }

  postMessage(bool logPost, String path) {
    Post post = new Post(postBody, widget.group.name, widget.user.id);

    post.postToFirebase(path);

    String logpath;
    List<String> list = path.split("posts");
    print(list[0]);
    logpath = "${list[0]}log";
    print(logpath);
    if (logPost == true) {
      post.logPost(logpath);
    }

    Navigator.of(context).pop();
  }
}
