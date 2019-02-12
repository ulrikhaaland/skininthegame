import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/utils/cloudFunctions.dart';

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
      this.url,
      this.callback,
      this.game,
      this.gameId})
      : super(key: key);
  final User user;
  final Group group;
  final Game game;
  final String playerId;
  final String playerUserName;
  final String url;
  final int oldAddon;
  final int oldRebuy;
  final int oldPlacing;
  final int oldPayout;
  final String gameId;
  final bool history;
  final VoidCallback callback;

  @override
  TournamentPlayerPageState createState() => TournamentPlayerPageState();
}

class TournamentPlayerPageState extends State<TournamentPlayerPage> {
  static final formKey = new GlobalKey<FormState>();
  Firestore firestoreInstance = Firestore.instance;

  TextEditingController myController = new TextEditingController();

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
  int newPayout;

  int oldAddon;
  int oldRebuy;
  int oldPlacing;
  int oldPayout;
  String gamePath;

  int genesisPayout;

  String activeOrHistory = "tournamentactive";

  @override
  void initState() {
    super.initState();

    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    groupName = widget.group.name;
    groupId = widget.group.id;

    myController.addListener(() => updatePayout());
    myController.text = widget.oldPlacing.toString();

    updatePayout();
    if (widget.history == true) {
      activeOrHistory = "tournamenthistory";
    }

    gamePath = "groups/$groupId/games/type/$activeOrHistory/${widget.gameId}";

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
      oldPayout = 0;
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
            newPayout = genesisPayout;
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

      if (newAddon != widget.oldAddon) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} addon from ${widget.oldAddon} to $newAddon",
            "$gamePath/log",
            "Addon");
      }
      if (newRebuy != widget.oldRebuy) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} rebuy from ${widget.oldRebuy} to $newRebuy",
            "$gamePath/log",
            "Rebuy");
      }
      if (newPayout != widget.oldPayout) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} payout from ${widget.oldPayout} to $newPayout",
            "$gamePath/log",
            "Payout");
      }
      if (newPlacing != widget.oldPlacing) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} placing from ${widget.oldPlacing} to $newPlacing",
            "$gamePath/log",
            "Placing");
      }

      setState(() {
        isLoading = false;
      });
    }
    Navigator.pop(context);
  }

  Widget addImage(String url) {
    if (url != null) {
      return new CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(url),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 20,
        child: Icon(
          Icons.person_outline,
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: Colors.grey[600],
      );
    }
  }

  void updatePayout() {
    if (myController.text != "") if (int.tryParse(myController.text) >
        widget.game.payoutList.length) {
      genesisPayout = 0;
    } else if (myController.text == "0") {
      genesisPayout = 0;
    } else {
      genesisPayout =
          widget.game.payoutList[int.tryParse(myController.text) - 1].payout;
    }
    setState(() {});
  }

  Widget page() {
    if (widget.group.admin) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          new ListTile(
            leading: addImage(widget.url),
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
          new ListTile(
            leading: new Icon(
              FontAwesomeIcons.award,
              size: 40.0,
              color: Colors.yellow[700],
            ),
            title: new TextField(
                keyboardType: TextInputType.number,
                style: new TextStyle(color: UIData.blackOrWhite),
                controller: myController,
                decoration: InputDecoration(
                  labelStyle: new TextStyle(color: Colors.grey[600]),
                  labelText: "Placing",
                ),
                onChanged: (val) {
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
              title: new Text("Payout: $genesisPayout${widget.game.currency}",
                  style: new TextStyle(
                      color: UIData.white, fontSize: UIData.fontSize18))),
          new ListTile(
            leading: new Icon(
              Icons.refresh,
              size: 40.0,
              color: UIData.blackOrWhite,
            ),
            title: new TextFormField(
                keyboardType: TextInputType.number,
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
                keyboardType: TextInputType.number,
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
            leading: addImage(widget.url),
            title: new Text(
              "${widget.playerUserName}",
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
          divider(),
          placing(),
          Layout().divider(),
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
          Layout().divider(),
          rebuys(),
          Layout().divider(),
          addons(),
          Layout().divider(),
        ],
      );
    }
  }

  Widget addons() {
    if (widget.game.addon > 0) {
      return new ListTile(
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
        trailing: request("addon"),
        onTap: null,
      );
    } else {
      return Container();
    }
  }

  Widget request(String type) {
    RaisedButton rBtn = new RaisedButton(
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: new Text("Request"),
        onPressed: () async {
          DocumentSnapshot docSnapA = await firestoreInstance
              .document("$gamePath/requests/${widget.user.id}a")
              .get();
          DocumentSnapshot docSnapR = await firestoreInstance
              .document("$gamePath/requests/${widget.user.id}r")
              .get();
          String an;
          String a;
          if (type == "addon") {
            an = "An";
            a = "a";
          } else {
            an = "A";
            a = "r";
          }
          if (type == "addon" && !docSnapA.exists ||
              type == "rebuy" && !docSnapR.exists) {
            String body =
                "${widget.user.userName} has requested ${an.toLowerCase()} $type";
            Essentials().showSnackBar("$an $type request has been sent",
                formKey.currentState.context);

            Log().postLogToCollection(body, "$gamePath/log", "Request");
            firestoreInstance
                .document("$gamePath/requests/${widget.user.id}$a")
                .setData({
              "type": type,
              "name": widget.user.userName,
              "id": widget.user.id,
            });
            OwnCloudFunctions().groupNotification(
              "Tournament!",
              widget.game,
              widget.group,
              "${widget.game.name.toUpperCase()} - ${type.toUpperCase()}",
              body,
              false,
            );
          } else {
            Essentials().showSnackBar(
                "You have already requested ${an.toLowerCase()} $type",
                formKey.currentState.context);
          }
        });
    if (type == "addon" && widget.playerId == widget.user.id) {
      if (widget.oldAddon < widget.game.addon) {
        return rBtn;
      }
    } else if (widget.oldRebuy < widget.game.rebuy &&
        widget.playerId == widget.user.id) {
      return rBtn;
    } else
      return null;
  }

  Widget rebuys() {
    if (widget.game.rebuy > 0) {
      return new ListTile(
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
        trailing: request("rebuy"),
        onTap: null,
      );
    } else {
      return new Container();
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
