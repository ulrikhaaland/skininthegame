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
            padding: EdgeInsets.only(
              left: 36,
              right: 36,
            ),
            child: new Container(
              decoration: new BoxDecoration(
                  color: UIData.listColor,
                  border: Border.all(color: Colors.grey[600]),
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(8.0))),
              child: new Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new Text(
                    "Some new changes has been made, \nplease update the app to continue",
                    style: new TextStyle(
                        fontSize: 25.0, color: UIData.blackOrWhite),
                  )),
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
