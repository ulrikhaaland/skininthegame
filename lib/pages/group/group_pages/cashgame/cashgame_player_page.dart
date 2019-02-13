import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/utils/cloudFunctions.dart';

class CashGamePlayerPage extends StatefulWidget {
  CashGamePlayerPage({
    Key key,
    this.playerId,
    this.playerUserName,
    this.user,
    this.buyinAmount,
    this.group,
    this.history,
    this.callBack,
    this.payout,
    this.game,
    this.url,
    this.createdPlayer,
    this.fromAll,
    this.onUpdate,
  }) : super(key: key);
  final User user;
  final Group group;
  final String playerId;
  final String playerUserName;
  final String url;
  final int buyinAmount;
  final int payout;
  final Game game;
  final bool history;
  final VoidCallback callBack;
  final VoidCallback onUpdate;
  final bool createdPlayer;
  final bool fromAll;

  @override
  CashGamePlayerPageState createState() => CashGamePlayerPageState();
}

class CashGamePlayerPageState extends State<CashGamePlayerPage> {
  static final formKey = new GlobalKey<FormState>();
  Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String currentUserName;
  bool userFound = false;
  bool isLoading = false;
  int oldPlayerBuyinAmount;
  int newPlayerBuyinAmount;
  int oldPayout;
  int newPayout;
  String sessionOrTotal = "Session";

  String activeOrHistory = "cashgameactive";
  String gamePath;

  @override
  void initState() {
    super.initState();

    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    oldPlayerBuyinAmount = widget.buyinAmount;
    oldPayout = widget.payout;
    if (widget.history) {
      activeOrHistory = "cashgamehistory";
    }
    if (widget.fromAll) {
      sessionOrTotal = "Total";
    }
    gamePath =
        "groups/${widget.group.id}/games/type/$activeOrHistory/${widget.game.id}";
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
              "Cash Game Player",
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

  setBuyin() async {
    if (validateAndSave()) {
      if (widget.fromAll) {
        if (oldPayout != newPayout) {
          Log().postLogToCollection(
              "$currentUserName changed ${widget.playerUserName} payout amount from $oldPayout to $newPayout",
              "$gamePath/log",
              "Payout");
        }
        if (oldPlayerBuyinAmount != newPlayerBuyinAmount) {
          Log().postLogToCollection(
              "$currentUserName changed ${widget.playerUserName} buyin amount from $oldPlayerBuyinAmount to $newPlayerBuyinAmount",
              "$gamePath/log",
              "Buyin");
        }
        if (oldPayout != newPayout ||
            oldPlayerBuyinAmount != newPlayerBuyinAmount) {
          firestoreInstance
              .document("$gamePath/players/${widget.playerId}")
              .updateData({
            "payout": newPayout,
            "buyin": newPlayerBuyinAmount,
          });
        }
      } else {
        int buyinAmount = 0;
        int payoutAmount = 0;
        if (!widget.history) {
          firestoreInstance
              .document("$gamePath/activeplayers/${widget.playerId}")
              .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});
        }
        // firestoreInstance
        //     .document(
        //         "$gamePath/activeplayers/${widget.playerId}")
        //     .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});
        if (oldPayout != newPayout) {
          payoutAmount = newPayout - oldPayout;

          Log().postLogToCollection(
              "$currentUserName changed ${widget.playerUserName} payout amount from $oldPayout to $newPayout",
              "$gamePath/log",
              "Payout");
        }
        if (oldPlayerBuyinAmount != newPlayerBuyinAmount) {
          buyinAmount = newPlayerBuyinAmount - oldPlayerBuyinAmount;

          Log().postLogToCollection(
              "$currentUserName changed ${widget.playerUserName} buyin amount from $oldPlayerBuyinAmount to $newPlayerBuyinAmount",
              "$gamePath/log",
              "Buyin");
        }
        if (buyinAmount != 0 || payoutAmount != 0) {
          await firestoreInstance.runTransaction((Transaction tx) async {
            DocumentReference docRef = firestoreInstance
                .document("$gamePath/players/${widget.playerId}");
            DocumentSnapshot docSnap = await tx.get(docRef);
            await tx.update(docRef, {
              "buyin": docSnap.data["buyin"] + buyinAmount,
              "payout": docSnap.data["payout"] + payoutAmount
            });
          });
        }
        setState(() {
          isLoading = false;
        });
      }
      widget.onUpdate();
    }

    Navigator.pop(context);
  }

  Widget page() {
    if (widget.group.admin == true) {
      return ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          new ListTile(
            leading: addImage(widget.url),
            title: new Text(
              "${widget.playerUserName}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              if (!widget.createdPlayer) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: widget.user,
                              profileId: widget.playerId,
                            )));
              }
            },
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new TextFormField(
              keyboardType: TextInputType.number,
              style: new TextStyle(color: UIData.blackOrWhite),
              initialValue: oldPlayerBuyinAmount.toString(),
              decoration: InputDecoration(
                labelStyle: new TextStyle(color: Colors.grey[600]),
                labelText: "$sessionOrTotal buyin amount",
              ),
              onSaved: (val) => val.isEmpty
                  ? newPlayerBuyinAmount = 0
                  : newPlayerBuyinAmount = int.tryParse(val),
            ),
            onTap: null,
          ),
          new Text(
            "This amount equals to how much money the player has bought in for",
            style: new TextStyle(
                fontSize: UIData.fontSize12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new TextFormField(
              keyboardType: TextInputType.number,
              style: new TextStyle(color: UIData.blackOrWhite),
              initialValue: oldPayout.toString(),
              decoration: InputDecoration(
                labelStyle: new TextStyle(color: Colors.grey[600]),
                labelText: "Payout",
              ),
              onSaved: (val) =>
                  val.isEmpty ? newPayout = 0 : newPayout = int.tryParse(val),
            ),
            onTap: null,
          ),
          new Text(
            "This amount equals to how much money the player had when player left the game",
            style: new TextStyle(
                fontSize: UIData.fontSize12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
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
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              if (!widget.createdPlayer) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: widget.user,
                              profileId: widget.playerId,
                            )));
              }
            },
          ),
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
              "Buyin: $oldPlayerBuyinAmount",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
            ),
            onTap: null,
          ),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          requestBuyin(),
          buyinText(),
          requestPayout(),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
        ],
      );
    }
  }

  Widget requestPayout() {
    if (!widget.history &&
        widget.playerId == widget.user.id &&
        widget.game.isRunning) {
      return new Column(
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              child: new PrimaryButton(
                  text: "Request payout",
                  onPressed: () async {
                    DocumentSnapshot docSnap = await firestoreInstance
                        .document("$gamePath/requests/${widget.user.id}p")
                        .get();
                    if (!docSnap.exists) {
                      Log().postLogToCollection(
                          "${widget.user.userName} has requested a payout",
                          "$gamePath/log",
                          "Request");

                      Essentials().showSnackBar(
                          "Your payout request has been sent",
                          formKey.currentState.context);
                      firestoreInstance
                          .document("$gamePath/requests/${widget.user.id}p")
                          .setData(
                        {
                          "name": widget.user.userName,
                          "id": widget.user.id,
                          "type": "payout",
                        },
                      );
                      OwnCloudFunctions().groupNotification(
                          "Cash Game!",
                          widget.game,
                          widget.group,
                          "${widget.game.name.toUpperCase()} - PAYOUT",
                          "${widget.user.userName} has requested a payout",
                          false);
                    } else {
                      Essentials().showSnackBar(
                          "A payout request has already been sent",
                          formKey.currentState.context);
                    }
                  })),
          new Padding(
              padding: EdgeInsets.only(left: 16),
              child: new Text(
                "Lets floor know you are done playing and wish to be payed out",
                style: new TextStyle(
                    fontSize: UIData.fontSize12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              )),
        ],
      );
    } else if (widget.history) {
      return new ListTile(
        leading: new Icon(
          Icons.attach_money,
          size: 40.0,
          color: UIData.green,
        ),
        title: new Text(
          "Payout: $oldPayout",
          style: new TextStyle(
              fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
        ),
        onTap: null,
      );
    } else {
      return new Container();
    }
  }

  Widget buyinText() {
    String text;
    oldPlayerBuyinAmount != 0
        ? text = "Request more chips"
        : text = "Request a buyin";
    if (!widget.history && widget.playerId == widget.user.id)
      return Padding(
          padding: EdgeInsets.only(top: 12),
          child: new Text(
            text,
            style: new TextStyle(
                fontSize: UIData.fontSize12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ));
    else
      return new Container();
  }

  Widget requestBuyin() {
    String text;
    oldPlayerBuyinAmount != 0 ? text = "Rebuy" : text = "Buyin";
    int buyin = 0;
    if (!widget.history && widget.playerId == widget.user.id)
      return new ListTile(
        title: new TextField(
          style: new TextStyle(color: UIData.blackOrWhite),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: text,
              labelStyle: new TextStyle(color: Colors.grey[600])),
          onChanged: (val) => buyin = int.tryParse(val),
        ),
        trailing: new RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: new Text("Request"),
            onPressed: () async {
              DocumentSnapshot docSnap = await firestoreInstance
                  .document("$gamePath/requests/${widget.user.id}r")
                  .get();
              if (!docSnap.exists) {
                if (buyin > 0) {
                  Log().postLogToCollection(
                      "${widget.user.userName} has requested a ${text.toLowerCase()} of $buyin",
                      "$gamePath/log",
                      "Request");
                  Essentials().showSnackBar(
                      "Your ${text.toLowerCase()} request has been sent",
                      formKey.currentState.context);
                  firestoreInstance
                      .document("$gamePath/requests/${widget.user.id}r")
                      .setData({
                    "name": widget.user.userName,
                    "addbuyin": buyin,
                    "currentbuyin": oldPlayerBuyinAmount,
                    "id": widget.user.id,
                    "type": text.toLowerCase(),
                  });
                  OwnCloudFunctions().groupNotification(
                      "Cash Game!",
                      widget.game,
                      widget.group,
                      "${widget.game.name} - ${text.toUpperCase()}",
                      "${widget.user.userName} has requested a ${text.toLowerCase()} of $buyin",
                      false);
                } else {
                  Essentials().showSnackBar(
                      "Buyin amount must be greater than 0",
                      formKey.currentState.context);
                }
              } else {
                Essentials().showSnackBar(
                    "A buyin request has already been sent",
                    formKey.currentState.context);
              }
            }),
      );
    // return new Padding(
    //     padding: EdgeInsets.fromLTRB(24, 12, 0, 12),
    //     child: new Row(
    //       children: <Widget>[
    //         new Text(
    //           "Request new buyin:",
    //           style: new TextStyle(
    //               fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
    //         ),
    //       ],
    //     ));
    else
      return new Container();
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

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      child: child,
    );
  }
}
