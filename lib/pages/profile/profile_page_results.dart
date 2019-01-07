import 'package:flutter/material.dart';
import 'package:yadda/objects/result.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/utils/uidata.dart';

class ProfilePageResults extends StatefulWidget {
  ProfilePageResults({this.result, this.user, this.title});
  final Result result;
  final User user;
  final String title;
  @override
  _ProfilePageResultsState createState() => _ProfilePageResultsState();
}

class _ProfilePageResultsState extends State<ProfilePageResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIData.dark,
      appBar: new AppBar(
        title: new Text(widget.title,
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize24)),
        backgroundColor: UIData.appBarColor,
      ),
      body: new Padding(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: data(),
        ),
      ),
    );
  }

  List<Widget> data() {
    List<Widget> list = new List<Widget>();

    if (widget.result.gameName != null) {
      list.add(new Align(
        alignment: Alignment.center,
        child: new Text(
          widget.result.gameName,
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
        ),
      ));
      list.add(new Container(
        height: 14,
      ));
    }
    if (widget.result.groupName != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Group: ${widget.result.groupName}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.gameType != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Game type: ${widget.result.gameType}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.placing != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Placing: ${widget.result.placing}/${widget.result.playerAmount}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.currency != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Currency: ${widget.result.currency}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.buyin != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Buyin: ${widget.result.buyin}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.prizePool != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Prize pool: ${widget.result.prizePool}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.payout != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Payout: ${widget.result.payout}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.profit != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Profit: ${widget.result.profit}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.rebuy != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Rebuy: ${widget.result.rebuy}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.addon != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Addon: ${widget.result.addon}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (widget.result.date != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Date: ${widget.result.date}/${widget.result.year} ${widget.result.time}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    return list;
  }
}
