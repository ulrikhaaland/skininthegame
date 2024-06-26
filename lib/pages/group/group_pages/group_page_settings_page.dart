import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/group/new/newInviteUser_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import '../../../service/service_provider.dart';
import 'package:yadda/widgets/report_dialog.dart';
import '../../../widgets/nav_helper_text.dart';
import 'package:yadda/widgets/nav_appbar.dart';

class GroupSettingsPage extends StatefulWidget {
  GroupSettingsPage(
      {Key key,
      this.user,
      this.newGroupOption,
      this.initState,
      this.onUpdate,
      this.group,
      this.navHelperTextList,
      this.publicGroup})
      : super(key: key);

  final VoidCallback initState;
  final VoidCallback onUpdate;
  final User user;
  final Group group;
  final bool publicGroup;
  final bool newGroupOption;
  final List<String> navHelperTextList;

  @override
  GroupSettingsPageState createState() => GroupSettingsPageState();
}

enum FormType { public, private }

class GroupSettingsPageState extends State<GroupSettingsPage> {
  static final formKey = new GlobalKey<FormState>();

  String currentUserId;
  String groupId;
  bool userFound = false;

  bool notificationSubscription = true;

  String groupCode = "";
  String reportMessage = "";

  final Firestore fireStoreInstance = Firestore.instance;

  initState() {
    super.initState();
    groupId = widget.group.id;
    currentUserId = widget.user.id;
    _getUserInfo();
  }

  _getUserInfo() async {
    DocumentSnapshot docSnap = await fireStoreInstance
        .document("groups/${widget.group.id}/members/${widget.user.id}")
        .get();
    notificationSubscription = docSnap.data["notification"];
    userFound = true;
    setScreen();
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
      setState(() {});
      return _newGame();
    }
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  Widget paddedHorizontal({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: .0),
      child: child,
    );
  }

  Widget paddedTwo({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.navHelperTextList.contains("Group")) {
      widget.navHelperTextList.add("Group");
    }
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: PreferredSize(
        preferredSize: Size(
            0, ServiceProvider.instance.screenService.getHeight(context) / 10),
        child: Container(
            color: UIData.appBarColor,
            child: NavAppBar(
              navItemList: widget.navHelperTextList,
              titleText: "Settings",
              actions: <Widget>[
                Column(
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.more_vert),
                      iconSize: UIData.iconSizeAppBar,
                      onPressed: () {
                        ReportDialog dialog = new ReportDialog(
                          text: "Report group",
                          reportedId: widget.group.id,
                          reportedById: widget.user.id,
                          type: "group",
                        );
                        showDialog(context: context, child: dialog);
                      },
                    )
                  ],
                ),
              ],
            )),
      ),
      backgroundColor: UIData.dark,
      body: setScreen(),
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
            child: new Form(child: new Column(children: _pageWidgets()))),
      ])),
    ])));
  }

  Widget notification() {
    return new ListTile(
      leading: new Icon(
        Icons.notifications,
        size: 40.0,
        color: UIData.green,
      ),
      title: new Text(
        "Notifications",
        style: new TextStyle(
          color: UIData.blackOrWhite,
          fontSize: UIData.fontSize20,
        ),
      ),
      trailing: new Checkbox(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        activeColor: UIData.green,
        value: notificationSubscription,
        onChanged: (bool val) {
          setState(() {
            notificationSubscription = val;
          });
          fireStoreInstance.runTransaction((Transaction tx) {
            fireStoreInstance
                .document("groups/${widget.group.id}/members/${widget.user.id}")
                .updateData({
              "notification": val,
            });
          });
        },
      ),
      onTap: null,
    );
  }

  Widget leaveGroup() {
    return new ListTile(
      leading: new Icon(Icons.exit_to_app, size: 40.0, color: UIData.red),
      title: new Text(
        "Leave Group",
        style: new TextStyle(
            color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
      ),
      onTap: () {
        _showAlert();
      },
    );
  }

  Widget divider() {
    return new Divider(
      height: .0,
      color: Colors.black,
    );
  }

  List<Widget> _pageWidgets() {
    if (widget.group.public != false) {
      return [
        new ListTile(
          leading: new Icon(
            Icons.supervised_user_circle,
            size: 40.0,
            color: UIData.blue,
          ),
          title: new Text(
            "Invite users",
            style: new TextStyle(
              color: UIData.blackOrWhite,
              fontSize: UIData.fontSize20,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InviteUserPage(
                        group: widget.group,
                        user: widget.user,
                        navHelperTextList: widget.navHelperTextList,
                      )),
            );
          },
        ),
        divider(),
        notification(),
        divider(),
        leaveGroup(),
        divider(),
      ];
    } else {
      return [
        notification(),
        divider(),
        leaveGroup(),
        divider(),
      ];
    }
  }

  void _showAlert() {
    AlertDialog dialog = new AlertDialog(
      backgroundColor: UIData.dark,
      title: new Text(
        "Are you sure you want to leave the group?",
        style: TextStyle(color: UIData.blackOrWhite),
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      content: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            onPressed: () {
              fireStoreInstance
                  .document("users/$currentUserId/groups/$groupId")
                  .delete();
              fireStoreInstance
                  .document("groups/$groupId/members/$currentUserId")
                  .delete();
              Navigator.of(context)..pop()..pop()..pop();
            },
            child: new Text(
              "Yes",
              style: TextStyle(
                color: UIData.red,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text(
              "Cancel",
              style: TextStyle(
                color: UIData.blue,
              ),
            ),
          ),
        ],
      )),
      actions: <Widget>[],
    );
    showDialog(context: context, child: dialog);
  }
}
