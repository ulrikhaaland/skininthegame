import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/utils/time.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/pages/profile/profile_page.dart';

class TournamentPlayerPage extends StatefulWidget {
  TournamentPlayerPage(
      {Key key,
      this.playerId,
      this.playerUserName,
      this.user,
      this.oldPayout,
      this.oldPlacing,
      this.oldAddon,
      this.oldRebuy,
      this.history,
      this.group,
      this.callback,
      this.gameId})
      : super(key: key);
  final User user;
  final Group group;
  final String playerId;
  final String playerUserName;
  final int oldAddon;
  final int oldRebuy;
  final int oldPlacing;
  final String oldPayout;
  final String gameId;
  final bool history;
  final VoidCallback callback;

  @override
  TournamentPlayerPageState createState() => TournamentPlayerPageState();
}

class TournamentPlayerPageState extends State<TournamentPlayerPage> {
  static final formKey = new GlobalKey<FormState>();
  Firestore firestoreInstance = Firestore.instance;

  String groupName;
  String groupId;
  String currentUserId;
  String currentUserName;
  String userName;
  String email;
  bool userFound = false;
  bool isLoading = false;
  bool admin;

  int newAddon;
  int newRebuy;
  int newPlacing;
  String newPayout;

  String logPath;

  int oldAddon;
  int oldRebuy;
  int oldPlacing;
  String oldPayout;

  String activeOrHistory = "tournamentactive";

  @override
  void initState() {
    super.initState();

    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    groupName = widget.group.name;
    groupId = widget.group.id;
    logPath =
        "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}/log";

    if (widget.history == true) {
      activeOrHistory = "tournamenthistory";
      logPath =
          "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}/log";
    }
    if (widget.oldAddon == null) {
      oldAddon = 0;
    } else {
      oldAddon = widget.oldAddon;
    }
    if (widget.oldRebuy == null) {
      oldRebuy = 0;
    } else {
      oldRebuy = widget.oldRebuy;
    }
    if (widget.oldPlacing == null) {
      oldPlacing = 0;
    } else {
      oldPlacing = widget.oldPlacing;
    }
    if (widget.oldPayout == null) {
      oldPayout = "0";
    } else {
      oldPayout = widget.oldPayout;
    }
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      isLoading = false;
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: UIData.blackOrWhite),
            actions: <Widget>[
              updateButton(),
            ],
            backgroundColor: UIData.appBarColor,
            title: new Text(
              "Tournament Player",
              style: new TextStyle(
                  fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
            )),
        backgroundColor: UIData.dark,
        body: new Stack(
          children: <Widget>[
            new Form(
              key: formKey,
              child: page(),
            ),
            circular(),
          ],
        ));
  }

  Widget updateButton() {
    if (widget.group.admin == true) {
      return new FlatButton(
          child: new Text(
            "Update",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              isLoading = true;
            });
            setBuyin();
          });
    } else {
      return new FlatButton(
        child: new Text(
          "",
          style: new TextStyle(
              fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          textAlign: TextAlign.center,
        ),
        onPressed: null,
      );
    }
  }

  Widget circular() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Text("");
    }
  }

  setBuyin() {
    if (validateAndSave()) {
      firestoreInstance
          .document(
              "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}/players/${widget.playerId}")
          .updateData({
        "addon": newAddon,
        "rebuy": newRebuy,
        "placing": newPlacing,
        "payout": newPayout,
      });
      if (widget.history != true) {
        firestoreInstance
            .document(
                "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}/activeplayers/${widget.playerId}")
            .updateData({
          "addon": newAddon,
          "rebuy": newRebuy,
          "placing": newPlacing,
          "payout": newPayout,
        });
      }

      if (newAddon != widget.oldAddon) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} addon from ${widget.oldAddon} to $newAddon",
            logPath,
            "Addon");
      }
      if (newRebuy != widget.oldRebuy) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} rebuy from ${widget.oldRebuy} to $newRebuy",
            logPath,
            "Rebuy");
      }
      if (newPayout != widget.oldPayout) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} payout from ${widget.oldPayout} to $newPayout",
            logPath,
            "Payout");
      }
      if (newPlacing != widget.oldPlacing) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} placing from ${widget.oldPlacing} to $newPlacing",
            logPath,
            "Placing");
      }

      setState(() {
        isLoading = false;
      });
    }
    Navigator.pop(context);
  }

  Widget page() {
    if (widget.group.admin == true) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          new ListTile(
            leading: new Icon(
              Icons.person,
              size: 40.0,
              color: Colors.blue,
            ),
            title: new Text(
              "${widget.playerUserName}",
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
            ),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            user: widget.user,
                            profileId: widget.playerId,
                          )),
                ),
          ),
          new Divider(
            height: 10.0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.delete,
              size: 40.0,
              color: UIData.red,
            ),
            title: new Text(
              "Remove Player",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
            ),
            onTap: () {
              widget.callback();
              String players = "activeplayers";

              if (widget.history == true) {
                players = "players";
              }
              firestoreInstance
                  .document(
                      "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}/$players/${widget.playerId}")
                  .delete();
              Log().postLogToCollection(
                  "$currentUserName removed ${widget.playerUserName} from game",
                  logPath,
                  "Remove");

              Navigator.pop(context);
            },
          ),
          new Divider(
            height: 10.0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              FontAwesomeIcons.award,
              size: 40.0,
              color: Colors.yellow[700],
            ),
            title: new TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                style: new TextStyle(color: UIData.blackOrWhite),
                initialValue: oldPlacing.toString(),
                decoration: InputDecoration(
                  labelStyle: new TextStyle(color: Colors.grey[600]),
                  labelText: "Placing",
                ),
                onSaved: (val) {
                  if (int.tryParse(val) == widget.oldPlacing) {
                    newPlacing = widget.oldPlacing;
                  } else {
                    newPlacing = int.tryParse(val);
                  }
                }),
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new TextFormField(
                style: new TextStyle(color: UIData.blackOrWhite),
                initialValue: oldPayout.toString(),
                decoration: InputDecoration(
                  labelStyle: new TextStyle(color: Colors.grey[600]),
                  labelText: "Payout",
                ),
                onSaved: (val) {
                  if ((val) == widget.oldPayout) {
                    newPayout = widget.oldPayout;
                  } else {
                    newPayout = (val);
                  }
                }),
          ),
          new ListTile(
            leading: new Icon(
              Icons.refresh,
              size: 40.0,
              color: UIData.blackOrWhite,
            ),
            title: new TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                style: new TextStyle(color: UIData.blackOrWhite),
                initialValue: oldRebuy.toString(),
                decoration: InputDecoration(
                  labelStyle: new TextStyle(color: Colors.grey[600]),
                  labelText: "Rebuys",
                ),
                onSaved: (val) {
                  if (int.tryParse(val) == widget.oldRebuy) {
                    newRebuy = widget.oldRebuy;
                  } else {
                    newRebuy = int.tryParse(val);
                  }
                }),
          ),
          new ListTile(
            leading: new Icon(
              Icons.add,
              size: 40.0,
              color: Colors.grey[600],
            ),
            title: new TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                style: new TextStyle(color: UIData.blackOrWhite),
                initialValue: oldAddon.toString(),
                decoration: InputDecoration(
                  labelStyle: new TextStyle(color: Colors.grey[600]),
                  labelText: "Addon",
                ),
                onSaved: (val) {
                  if (int.tryParse(val) == widget.oldAddon) {
                    newAddon = widget.oldAddon;
                  } else {
                    newAddon = int.tryParse(val);
                  }
                }),
          ),
        ],
      );
    } else {
      return new ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          new ListTile(
            leading: new Icon(
              Icons.person,
              size: 40.0,
              color: Colors.blue,
            ),
            title: new Text(
              "${widget.playerUserName}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
            ),
          ),
          divider(),
          placing(),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new Text(
              "Payout:  ${widget.oldPayout}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: null,
          ),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.refresh,
              size: 40.0,
              color: UIData.blackOrWhite,
            ),
            title: new Text(
              "Rebuys: ${widget.oldRebuy}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: null,
          ),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.add,
              size: 40.0,
              color: Colors.grey[600],
            ),
            title: new Text(
              "Addons: ${widget.oldAddon}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: null,
          ),
        ],
      );
    }
  }

  Widget placing() {
    return new ListTile(
      leading: new Icon(
        FontAwesomeIcons.award,
        size: 40.0,
        color: Colors.yellow[700],
      ),
      title: new Text(
        "Placing: ${widget.oldPlacing}",
        style: new TextStyle(
            fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  divider() {
    return new Divider(
      height: .0,
      color: Colors.black,
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
