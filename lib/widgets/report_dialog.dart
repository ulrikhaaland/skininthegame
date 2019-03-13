import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/objects/user.dart';

class ReportDialog extends StatelessWidget {
  ReportDialog({
    this.key,
    this.text,
    this.color,
    this.reportedId,
    this.reportedById,
    this.type,
    this.postId,
  }) : super(key: key);
  final Key key;
  final String text;
  final Color color;
  final String reportedId;
  final String reportedById;
  final String type;
  String message;
  final String postId;

  Firestore fireStoreInstance = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
        backgroundColor: UIData.dark,
        contentPadding: EdgeInsets.all(20.0),
        content: new Container(
          height: 250,
          child: new Column(
            children: <Widget>[
              new ListTile(
                leading: new Icon(
                  Icons.flag,
                  color: Colors.yellow[700],
                ),
                title: new Text(
                  text,
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
              ),
              new TextField(
                style: new TextStyle(color: UIData.blackOrWhite),
                decoration: InputDecoration(
                    hintText: "Explain behavior",
                    hintStyle: TextStyle(color: Colors.grey[600])),
                maxLines: 3,
                onChanged: (val) => message = val,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              Padding(
                padding: EdgeInsets.only(top: 36),
              ),
              new PrimaryButton(
                  text: "Report",
                  onPressed: () {
                    if (postId != null) {
                      fireStoreInstance.collection("reports/type/$type").add(
                        {
                          "reportedid": reportedId,
                          "reportedbyid": reportedById,
                          "message": message,
                          "postid": postId,
                        },
                      );
                    }
                    fireStoreInstance.collection("reports/type/$type").add(
                      {
                        "reportedid": reportedId,
                        "reportedbyid": reportedById,
                        "message": message,
                      },
                    );
                    Navigator.pop(context);
                  }),
            ],
          ),
        ));
  }
}
