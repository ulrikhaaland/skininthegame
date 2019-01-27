import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:launch_review/launch_review.dart';
import 'package:yadda/widgets/primary_button.dart';

class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: UIData.dark,
      body: new Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(left: 36, right: 36,),
            child: new Text(
              "Some new changes have been made, please update the app to continue",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(left: 36, right: 36, top: 24),
            child: new PrimaryButton(
              text: "Update",
              color: UIData.yellow,
              onPressed: () {
                LaunchReview.launch(iOSAppId: '1440276360');
              },
            ),
          ),
        ],
      )),
    );
  }
}
