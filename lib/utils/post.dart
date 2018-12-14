import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/time.dart';

class Post {
  Post(this.body, this.posterName, this.posterId);

  String body;
  String posterName;
  String posterId;

  postToFirebase(String path) {
    Time time = new Time();
    Firestore.instance.collection(path).add({
      "body": this.body,
      "name": this.posterName,
      "posterid": this.posterId,
      "orderbytime": time.getOrderByTime(),
      "time": time.getFormattedTime(),
      "date": time.getFormattedDate(),
      "dayofweek": time.getDayOfWeek(),
    });
  }

  logPost(String path) {
    Time time = new Time();
    Firestore.instance.collection(path).add({
      "username": this.posterName,
      "uid": this.posterId,
      "logbody": "${this.posterName} made a new post",
      "orderbytime": time.getOrderByTime(),
      "time": time.getFormattedTime(),
      "date": time.getFormattedDate(),
      "dayofweek": time.getDayOfWeek(),
      "title": "Post",
    });
  }
}
