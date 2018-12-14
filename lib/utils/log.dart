import 'time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  postLogToCollection(String body, String path, String title) {
    Time time = new Time();
    Firestore.instance.collection(path).add({
      "logbody": body,
      "orderbytime": time.getOrderByTime(),
      "time": time.getFormattedTime(),
      "date": time.getFormattedDate(),
      "dayofweek": time.getDayOfWeek(),
      "title": title,
    });
  }
}
