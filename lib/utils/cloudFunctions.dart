import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/group.dart';

class CloudFunctions {
  Firestore firestoreInstance = Firestore.instance;
  var base =
      'https://us-central1-login-5a8c9.cloudfunctions.net/sendNotification2';
  var fcm =
      "croX4pJoOmA:APA91bHoE85_Qe853vmo4aFzinIjyIIhh__Y-R2Z4Oudcj2QAPkLk01xsdiI2Zsks4yOakqFCZfoRBgqPDIJi37MmgOjKmnTyODGFu_c-6PZk9wXsIM92gliTuIt-tlH7sS4d8DjWb42";

  groupNotification(String gameName, String groupName, String fromGroupId,
      int fromGameId, String gameType, Group group) async {
    await firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await Firestore.instance
          .collection("groups/$fromGroupId/members")
          .getDocuments();
      qSnap.documents.forEach((DocumentSnapshot doc) async {
        if (doc.data["notifications"] == true && doc.data["fcm"] != null) {
          print("${doc.data["fcm"]}");
          String dataURL =
              '$base?to=${doc.data["fcm"]}&gameName=$gameName&groupName=$groupName&fromGroupId=$fromGroupId&fromGameId=$fromGameId&gameType=$gameType&dailyMessage=${group.dailyMessage}&host=${group.host}&info=${group.info}&lowerCaseName=${group.lowerCaseName}&members=${group.members}&public=${group.public}&thumbs=${group.rating}';
          print(dataURL);

          await http.get(dataURL);
        }
      });
    });
  }

  deleteGroup(String groupId) {
    firestoreInstance.runTransaction((Transaction tx) async {
      String dataURL =
          "https://us-central1-login-5a8c9.cloudfunctions.net/deleteGroup?groupId=$groupId";
      await http.get(dataURL);
    });
  }
}
