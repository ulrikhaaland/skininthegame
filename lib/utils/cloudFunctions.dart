import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/objects/game.dart';

class OwnCloudFunctions {
  Firestore firestoreInstance = Firestore.instance;
  var base =
      'https://us-central1-login-5a8c9.cloudfunctions.net/sendNotification2';
  var fcm =
      "croX4pJoOmA:APA91bHoE85_Qe853vmo4aFzinIjyIIhh__Y-R2Z4Oudcj2QAPkLk01xsdiI2Zsks4yOakqFCZfoRBgqPDIJi37MmgOjKmnTyODGFu_c-6PZk9wXsIM92gliTuIt-tlH7sS4d8DjWb42";

  groupNotification(
    String gameType,
    Game game,
    Group group,
    String title,
    String body,
    bool newGame,
  ) async {
    if (newGame) {
      await firestoreInstance.runTransaction((Transaction tx) async {
        QuerySnapshot qSnap = await Firestore.instance
            .collection("groups/${group.id}/members")
            .getDocuments();
        qSnap.documents.forEach((DocumentSnapshot doc) async {
          if (doc.data["notification"] == true && doc.data["fcm"] != null) {
            print("${doc.data["fcm"]}");
            String dataURL =
                '$base?to=${doc.data["fcm"]}&gameName=${game.name}&groupName=${group.name}&fromGroupId=${group.id}&fromGameId=${game.id}&gameType=$gameType&dailyMessage=${group.dailyMessage}&host=${group.host}&info=${group.info}&lowerCaseName=${group.lowerCaseName}&members=${group.members}&public=${group.public}&thumbs=${group.rating}&title=$title&body=$body&uid=${doc.documentID}';
            print(dataURL);

            await http.get(dataURL);
          }
        });
      });
    } else {
      String dataURL =
          '$base?to=${game.floorFCM}&gameName=${game.name}&groupName=${group.name}&fromGroupId=${group.id}&fromGameId=${game.id}&gameType=$gameType&dailyMessage=${group.dailyMessage}&host=${group.host}&info=${group.info}&lowerCaseName=${group.lowerCaseName}&members=${group.members}&public=${group.public}&thumbs=${group.rating}&title=$title&body=$body&uid=${game.floor}';
      await http.get(dataURL);
    }
  }

  deleteGroup(String groupId) {
    firestoreInstance.runTransaction((Transaction tx) async {
      String dataURL =
          "https://us-central1-login-5a8c9.cloudfunctions.net/deleteGroup?groupId=$groupId";
      await http.get(dataURL);
    });
  }
}
