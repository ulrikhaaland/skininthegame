import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/group/new/newGroup.dart';
import 'newInviteUser_page.dart';
import 'newInvitationCode_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/utils/delete.dart';

class New extends StatefulWidget {
  New(
      {Key key,
      this.user,
      this.newGroupOption,
      this.admin,
      this.initState,
      this.onUpdate,
      this.group})
      : super(key: key);
  final VoidCallback initState;
  final VoidCallback onUpdate;
  final User user;
  final Group group;
  final bool admin;
  final bool newGroupOption;

  @override
  NewState createState() => NewState();
}

enum FormType { public, private }

class NewState extends State<New> {
  static final formKey = new GlobalKey<FormState>();

  String currentUserId;
  String dailyMessage = "";
  String info;
  String groupId;
  String groupName;
  bool userFound = false;

  bool isLoading = false;

  Essentials loading = new Essentials();

  String publicPrivateText;

  IconData privateIcon;
  IconData publicIcon;
  Color privateIconColor;
  Color publicIconColor;

  final Firestore firestoreInstance = Firestore.instance;
  @override
  initState() {
    super.initState();
    currentUserId = widget.user.id;
    if (widget.group.public == false) {
      publicIcon = Icons.visibility_off;
      publicPrivateText = "Private groups can only be joined via an invite. \n";
    } else {
      publicPrivateText =
          "Public groups can be found in search, anyone can see and join them.\n";
      publicIcon = Icons.visibility;
    }
    if (widget.newGroupOption == true) {
      userFound = true;
      setScreen();
      setState(() {});
    } else {
      info = widget.group.dailyMessage;
      groupId = widget.group.id;
      groupName = widget.group.name;
      dailyMessage = widget.group.dailyMessage;
      userFound = true;
      setScreen();
      setState(() {});
    }
  }

  setScreen() {
    if (userFound == false) {
      return loading.loading(true);
    } else {
      return _newGame();
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
        elevation: 4,
        actions: <Widget>[
          new FlatButton(
              child: new Text(
                "Update",
                style: new TextStyle(
                    fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
                textAlign: TextAlign.center,
              ),
              onPressed: () => _pushInfo()),
        ],
        backgroundColor: UIData.appBarColor,
        title: new Text(
          "Settings",
          style: new TextStyle(
              fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
        ),
      ),
      backgroundColor: UIData.dark,
      body: new Stack(
        children: <Widget>[
          setScreen(),
          loading.loading(isLoading),
        ],
      ),
    );
  }

  Widget _newGame() {
    return new SingleChildScrollView(
        child: new Container(
            child: new Column(children: [
      new Container(
          child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        new Container(
            padding: const EdgeInsets.all(16.0),
            child: new Form(
                key: formKey, child: new Column(children: _pageWidgets()))),
      ])),
    ])));
  }

  List<Widget> _pageWidgets() {
    if (widget.newGroupOption == true) {
      return [
        new ListTile(
          leading: new Icon(
            Icons.people,
            color: Colors.blue,
            size: 40.0,
          ),
          title: new Text(
            "New Group",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewGroup(
                        user: widget.user,
                        onUpdate: () => widget.onUpdate(),
                      )),
            );
          },
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
          leading: new Icon(
            Icons.account_balance,
            color: Colors.yellow[700],
            size: 40.0,
          ),
          title: new Text(
            "New League",
            style: new TextStyle(
              color: UIData.blackOrWhite,
              fontSize: UIData.fontSize20,
            ),
          ),
          onTap: null,
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
      ];
    } else if (widget.admin == true) {
      return [
        new ListTile(
          leading: new Icon(
            Icons.supervised_user_circle,
            color: UIData.blue,
            size: 40.0,
          ),
          title: new Text(
            "Invite Users",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
          ),
          onTap: () {
            setState(() {
              isLoading = true;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InviteUserPage(
                        user: widget.user,
                        group: widget.group,
                      )),
            );

            setState(() {
              isLoading = false;
            });
          },
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
          leading: new Icon(
            Icons.local_post_office,
            color: Colors.yellow[700],
            size: 40.0,
          ),
          title: new Text(
            "Invitation Codes",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
          ),
          onTap: () async {
            setState(() {
              isLoading = true;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InvitationCodePage(
                        user: widget.user,
                        group: widget.group,
                      )),
            );

            setState(() {
              isLoading = false;
            });
          },
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
          leading: new Icon(
            publicIcon,
            color: UIData.blackOrWhite,
            size: 40.0,
          ),
          title: new Text(
            "Public",
            style: new TextStyle(color: UIData.blackOrWhite, fontSize: 20.0),
          ),
          trailing: new Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            activeColor: UIData.green,
            value: widget.group.public,
            onChanged: (bool val) {
              if (val) {
                publicPrivateText =
                    "Public groups can be found in search, anyone can see and join them.\n";
                publicIcon = Icons.visibility;
              } else {
                publicPrivateText =
                    "Private groups can only be joined via an invite. \n\n";

                publicIcon = Icons.visibility_off;
              }
              setState(() {
                widget.group.public = val;
              });
              widget.group.setPublic(val);
            },
          ),
        ),
        new Align(
          alignment: Alignment.center,
          child: new Text(
            publicPrivateText,
            style: new TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
          leading: Icon(
            Icons.attach_money,
            size: 40,
            color: Colors.green,
          ),
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
            value: widget.group.shareResults,
            onChanged: (bool val) {
              setState(() {
                widget.group.shareResults = val;
              });
              widget.group.setShareResults(val);
            },
          ),
        ),
        new Align(
          alignment: Alignment.center,
          child: new Text(
            "Allow group members to share their results with others. \n",
            style: new TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        new Divider(
          height: .0,
          color: Colors.black,
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
              initialValue: widget.group.dailyMessage,
              maxLines: 2,
              maxLength: 160,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // UnderlineInputBorder(
                  //     borderSide: BorderSide(color: UIData.blackOrWhite)),
                  labelText: "Daily message...",
                  labelStyle: TextStyle(color: Colors.grey[600])),
              onSaved: (val) {
                widget.group.dailyMessage = val;
              },
            ),
          ),
        ),

        // Padding(
        //   padding: EdgeInsets.only(top: 16),
        // ),
        Divider(
          height: 0.1,
          color: Colors.black,
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
              initialValue: widget.group.info,
              maxLines: 2,
              maxLength: 160,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // UnderlineInputBorder(
                  //     borderSide: BorderSide(color: UIData.blackOrWhite)),
                  labelText: "Group description...",
                  labelStyle: TextStyle(color: Colors.grey[600])),
              onSaved: (val) {
                widget.group.info = val;
              },
            ),
          ),
        ),
        Divider(
          height: 0.1,
          color: Colors.black,
        ),
        Padding(
          padding: EdgeInsets.only(top: 24.0),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 24.0,
          ),
        ),
        deleteGroupButton(),
        leaveGroupButton(),
      ];
    }
  }

  Widget deleteGroupButton() {
    if (widget.group.host == widget.user.id) {
      return new PrimaryButton(
        text: "Delete Group",
        color: UIData.red,
        onPressed: () {
          // CloudFunctions().deleteGroup(widget.group.id);
          _showDeleteGroupAlert();
        },
      );
    } else {
      return new Text("");
    }
  }

  Widget leaveGroupButton() {
    if (widget.admin == true && widget.group.host != widget.user.id) {
      return new PrimaryButton(
          text: "Leave Group",
          color: UIData.red,
          onPressed: () {
            _showLeaveGroupAlert();
          });
    } else {
      return new Text("");
    }
  }

  void _showDeleteGroupAlert() {
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Delete group?",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            Navigator.pop(context);
            Delete().deleteGroup(widget.group.id);
            setState(() {
              isLoading = false;
            });
            Navigator.of(context)..pop()..pop();
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }

  void _showLeaveGroupAlert() {
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Leave group?",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            firestoreInstance
                .document("users/$currentUserId/groups/$groupId")
                .delete();
            firestoreInstance
                .document("groups/$groupId/members/$currentUserId")
                .delete();

            Navigator.of(context)..pop()..pop()..pop();
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }

  _pushInfo() {
    if (validateAndSave()) {
      if (widget.group.dailyMessage == null) {
        widget.group.dailyMessage = "";
      }
      if (widget.group.info == null) {
        widget.group.info = "";
      }
      firestoreInstance.document("groups/$groupId").updateData({
        "dailymessage": widget.group.dailyMessage,
        'info': widget.group.info
      });
      widget.initState();
      Navigator.pop(context);
    }
  }
}
