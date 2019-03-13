import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';

class MyData extends StatelessWidget {
  MyData({this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    String subLevelText = "";
    switch (user.subLevel) {
      case (0):
        subLevelText = "Fish Plan (Free)";
        break;
        case (1):
        subLevelText = "Shark Plan";
        break;
        case (2):
        subLevelText = "Whale Plan";
        break;
      default:
    }
    return Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
        backgroundColor: UIData.appBarColor,
        title: new Text(
          "My Data",
          style: TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(
                "Username",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              subtitle: new Text(
                user.userName,
                style: TextStyle(
                  color: UIData.blackOrWhite,
                  fontSize: UIData.fontSize18,
                ),
              ),
            ),
            new ListTile(
              title: new Text(
                "Email",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              subtitle: new Text(
                user.email,
                style: TextStyle(
                  color: UIData.blackOrWhite,
                  fontSize: UIData.fontSize18,
                ),
              ),
            ),
            new ListTile(
              title: new Text(
                "User ID",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              subtitle: new Text(
                user.id,
                style: TextStyle(
                  color: UIData.blackOrWhite,
                  fontSize: UIData.fontSize18,
                ),
              ),
            ),
            new ListTile(
              title: new Text(
                "Subscription Type",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              subtitle: new Text(
                subLevelText,
                style: TextStyle(
                  color: UIData.blackOrWhite,
                  fontSize: UIData.fontSize18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
