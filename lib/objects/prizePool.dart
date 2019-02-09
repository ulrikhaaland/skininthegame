import 'package:flutter/material.dart';

class PrizePoolList {
  List<double> list;
  PrizePoolList(int count) {
    list = List();
    if (count < 13) {
      thirteen();
    } else if (count < 20) {
      twenty();
    } else if (count < 30) {
      thirty();
    } else if (count < 40) {
      fourty();
    } else if (count < 50) {
      fifty();
    } else if (count < 60) {
      sixty();
    } else if (count < 70) {
      seventy();
    } else if (count < 80) {
      eighty();
    } else if (count < 100) {
      hundred1();
    } else if (count < 120) {
      hundred20();
    } else if (count < 140) {
      hundred40();
    } else if (count < 160) {
      hundred60();
    } else if (count < 180) {
      hundred80();
    } else if (count < 200) {
      twoHundred();
    } else if (count < 234) {
      twoHundred34();
    } else if (count < 267) {
      twoHundred67();
    } else if (count < 300) {
      threeHundred();
    } else if (count < 334) {
      threeHundred34();
    } else if (count < 367) {
      threeHundred67();
    } else if (count < 400) {
      fourHundred();
    } else if (count < 450) {
      fourHundred50();
    }
  }

  void thirteen() {
    list.add(70.00);
    list.add(30.00);
  }

  void twenty() {
    list.add(50.00);
    list.add(30.00);
    list.add(20.00);
  }

  void thirty() {
    list.add(40.00);
    list.add(30.00);
    list.add(20.00);
    list.add(10.00);
  }

  void fourty() {
    list.add(37.00);
    list.add(27.00);
    list.add(18.00);
    list.add(10.00);
    list.add(8.00);
  }

  void fifty() {
    list.add(34.00);
    list.add(25.00);
    list.add(17.00);
    list.add(10.00);
    list.add(8.00);
    list.add(6.00);
  }

  void sixty() {
    list.add(33.00);
    list.add(24.00);
    list.add(16.00);
    list.add(9.50);
    list.add(7.50);
    list.add(5.50);
    list.add(4.50);
  }

  void seventy() {
    list.add(32.00);
    list.add(23.00);
    list.add(15.25);
    list.add(9.00);
    list.add(7.25);
    list.add(5.50);
    list.add(4.50);
    list.add(3.50);
  }

  void eighty() {
    list.add(31.25);
    list.add(22.25);
    list.add(14.75);
    list.add(8.75);
    list.add(7.00);
    list.add(5.25);
    list.add(4.25);
    list.add(3.50);
    list.add(3.00);
  }

  void hundred1() {
    list.add(31.00);
    list.add(22.00);
    list.add(14.00);
    list.add(8.50);
    list.add(7.00);
    list.add(5.00);
    list.add(4.00);
    list.add(3.00);
    list.add(2.75);
    list.add(2.75);
  }

  void hundred20() {
    list.add(30.50);
    list.add(21.50);
    list.add(13.50);
    list.add(8.50);
    list.add(7.00);
    list.add(5.00);
    list.add(4.00);
    list.add(3.00);
    list.add(2.50);
    list.add(2.50);
    list.add(2.00);
  }

  void hundred40() {
    list.add(30.00);
    list.add(21.25);
    list.add(13.25);
    list.add(8.25);
    list.add(6.50);
    list.add(5.00);
    list.add(4.00);
    list.add(3.00);
    list.add(2.25);
    list.add(1.75);
    list.add(1.75);
    list.add(1.50);
    list.add(1.50);
  }

  void hundred60() {
    list.add(29.50);
    list.add(20.75);
    list.add(13.00);
    list.add(8.00);
    list.add(6.25);
    list.add(4.75);
    list.add(3.75);
    list.add(2.75);
    list.add(2.00);
    list.add(1.75);
    list.add(1.50);
    list.add(1.50);
    list.add(1.50);
    list.add(1.50);
    list.add(1.50);
  }

  void hundred80() {
    list.add(29.00);
    list.add(20.25);
    list.add(12.75);
    list.add(7.75);
    list.add(6.00);
    list.add(4.75);
    list.add(3.75);
    list.add(2.75);
    list.add(2.00);
    list.add(1.75);
    list.add(1.50);
    list.add(1.50);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
  }

  void twoHundred() {
    list.add(28.50);
    list.add(19.75);
    list.add(12.25);
    list.add(7.50);
    list.add(5.75);
    list.add(4.75);
    list.add(3.75);
    list.add(2.75);
    list.add(2.00);
    list.add(1.75);
    list.add(1.50);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
  }

  void twoHundred34() {
    list.add(28.00);
    list.add(19.00);
    list.add(12.25);
    list.add(7.25);
    list.add(5.50);
    list.add(4.50);
    list.add(3.50);
    list.add(2.75);
    list.add(2.00);
    list.add(1.75);
    list.add(1.50);
    list.add(1.50);
    list.add(1.25);
    list.add(1.25);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
  }

  void twoHundred67() {
    list.add(27.50);
    list.add(18.25);
    list.add(12.00);
    list.add(7.25);
    list.add(5.40);
    list.add(4.40);
    list.add(3.40);
    list.add(2.75);
    list.add(2.00);
    list.add(1.50);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(0.90);
    list.add(0.90);
  }

  void threeHundred() {
    list.add(27.00);
    list.add(18.00);
    list.add(12.00);
    list.add(7.00);
    list.add(5.40);
    list.add(4.40);
    list.add(3.40);
    list.add(2.65);
    list.add(1.90);
    list.add(1.50);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(1.00);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
    list.add(0.75);
  }

  void threeHundred34() {
    list.add(26.75);
    list.add(17.75);
    list.add(11.75);
    list.add(7.00);
    list.add(5.30);
    list.add(4.30);
    list.add(3.30);
    list.add(2.50);
    list.add(1.90);
    list.add(1.40);
    list.add(1.25);
    list.add(1.25);
    list.add(1.25);
    list.add(1.0);
    list.add(1.0);
    list.add(1.0);
    list.add(1.0);
    list.add(1.0);
    list.add(0.80);
    list.add(0.80);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
  }

  void threeHundred67() {
    list.add(26.00);
    list.add(17.50);
    list.add(11.50);
    list.add(6.80);
    list.add(5.25);
    list.add(4.30);
    list.add(3.30);
    list.add(2.50);
    list.add(1.90);
    list.add(1.40);
    list.add(1.25);
    list.add(1.20);
    list.add(1.20);
    list.add(1.00);
    list.add(1.00);
    list.add(0.90);
    list.add(0.90);
    list.add(0.90);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
  }

  void fourHundred() {
    list.add(26.00);
    list.add(17.25);
    list.add(11.25);
    list.add(6.80);
    list.add(5.10);
    list.add(4.20);
    list.add(3.30);
    list.add(2.40);
    list.add(1.80);
    list.add(1.40);
    list.add(1.20);
    list.add(1.20);
    list.add(1.20);
    list.add(1.00);
    list.add(1.00);
    list.add(0.80);
    list.add(0.80);
    list.add(0.80);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
  }

  void fourHundred50() {
    list.add(26.00);
    list.add(17.00);
    list.add(11.25);
    list.add(6.75);
    list.add(5.10);
    list.add(4.20);
    list.add(3.30);
    list.add(2.40);
    list.add(1.80);
    list.add(1.40);
    list.add(1.20);
    list.add(1.20);
    list.add(1.20);
    list.add(1.00);
    list.add(1.00);
    list.add(0.80);
    list.add(0.80);
    list.add(0.80);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.70);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.60);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
    list.add(0.50);
  }
}
