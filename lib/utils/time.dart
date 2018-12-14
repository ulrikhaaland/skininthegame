import 'package:flutter/material.dart';

class Time {
  int finalDate;
  int finalTime;
  int finalDateAndTime;
  String _date;
  String _time;
  String _day;

  getDate() {
    _date = new DateTime.now().toString();
  }

  getTime() {
    _time = new TimeOfDay.now().toString();
  }

  String getDayOfWeek() {
    int weekday;
    weekday = new DateTime.now().weekday;
    switch (weekday) {
      case (1):
        _day = "Monday";
        break;
      case (2):
        _day = "Tuesday";
         break;
      case (3):
        _day = "Wednesday";
         break;
      case (4):
        _day = "Thursday";
         break;
      case (5):
        _day = "Friday";
         break;
      case (6):
        _day = "Saturday";
         break;
      case (7):
        _day = "Sunday";
         break;
    }
    print(_day);
    return _day;
  }

  String getFormattedDate() {
    getDate();
    _date = _date.toString();
    List parts = _date.split(" ");
    print(parts[0]);

    _date = parts[0];

    List parts2 = _date.split("2018-");
    _date = parts2[1];
    print(_date);
    List parts3 = _date.split("-");
    _date = "${parts3[1]}/${parts3[0]}";
    print(_date);
    return _date;
  }

  String getFormattedTime() {
    getTime();
    _time = _time.toString();
    List parts = _time.split("y");
    List parts1 = parts[1].split("(");
    List parts2 = parts1[1].split(")");
    print(parts2[0]);
    if (parts[0] == "TimeOfDa") {
      _time = "${parts2[0]}PM";
    } else {
      _time = "${parts2[0]}AM";
    }
    return _time;
  }

  int getOrderByTime() {
    getDate();
    getTime();

    List parts = _date.split(" ");
    _date = parts[0];
    String parts2 = _date.replaceAll("-", "");
    finalDate = int.parse(parts2);

    String timeReplace1 = _time.replaceAll("(", "");
    String timeReplace2 = timeReplace1.replaceAll(")", "");
    List timeParts = timeReplace2.split("y");
    _time = timeParts[1];
    String timeReplace3 = _time.replaceAll(":", "");
    finalTime = int.parse(timeReplace3);

    finalDateAndTime = int.parse("$parts2$timeReplace3");
    return finalDateAndTime;
  }
}
