import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UIData {
  //routes
  static const String homeRoute = "/home";
  static const String profileOneRoute = "/View Profile";
  static const String notFoundRoute = "/No Search Result";
  static const String timelineOneRoute = "/Feed";
  static const String timelineTwoRoute = "/Tweets";
  static const String settingsOneRoute = "/Device Settings";
  static const String shoppingOneRoute = "/Shopping List";
  static const String shoppingTwoRoute = "/Shopping Details";
  static const String shoppingThreeRoute = "/Product Details";
  static const String paymentOneRoute = "/Credit Card";
  static const String loginOneRoute = "/Login With OTP";
  static const String dashboardOneRoute = "/Dashboard 1";
  static const String dashboardTwoRoute = "/Dashboard 2";

  //strings
  static const String appName = "Flutter UIKit";

  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  //images
  static const String imageDir = "assets/images";
  static const String pkImage = "$imageDir/pk.jpg";
  static const String profileImage = "$imageDir/profile.jpg";
  static const String blankImage = "$imageDir/blank.jpg";
  static const String dashboardImage = "$imageDir/dashboard.jpg";
  static const String loginImage = "$imageDir/login.jpg";
  static const String paymentImage = "$imageDir/payment.jpg";
  static const String settingsImage = "$imageDir/setting.jpeg";
  static const String shoppingImage = "$imageDir/shopping.jpeg";
  static const String timelineImage = "$imageDir/timeline.jpeg";
  static const String verifyImage = "$imageDir/verification.jpg";

  //login
  static const String enter_code_label = "Phone Number";
  static const String enter_code_hint = "10 Digit Phone Number";
  static const String enter_otp_label = "OTP";
  static const String enter_otp_hint = "4 Digit OTP";
  static const String get_otp = "Get OTP";
  static const String resend_otp = "Resend OTP";
  static const String login = "Login";
  static const String enter_valid_number = "Enter 10 digit phone number";
  static const String enter_valid_otp = "Enter 4 digit otp";

  //gneric
  static const String error = "Error";
  static const String success = "Success";
  static const String ok = "OK";
  static const String forgot_password = "Forgot Password?";
  static const String something_went_wrong = "Something went wrong";
  static const String coming_soon = "Coming Soon";

  static const MaterialColor ui_kit_color = Colors.grey;

//fontSize
  static const double fontSize12 = 12.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;

// IconSize

  static const double iconSizeAppBar = 35.0;
  static const double iconSizeBiggest = 40.0;
  static const double iconSizeTabBar = 30.0;

//colors
  static Color dark = Color.fromRGBO(36, 52, 71, 1.0);
  static Color darkest = Color.fromRGBO(20, 29, 38, 1.0);
  static Color red = Color.fromRGBO(197, 31, 93, 1.0);
  static Color cardColor = Color.fromRGBO(36, 52, 71, 1.0);

  static Color green = Colors.green;
  static Color blue = Colors.blue;
  static Color white = Color.fromRGBO(247, 240, 231, 1.0);
  static Color blackOrWhite = Color.fromRGBO(247, 240, 231, 1.0);
  static Color whiteOrBlack = Colors.black;
  static Color yellow = Color.fromRGBO(251, 192, 45, 1.0);
  static Color appBarColor = Color.fromRGBO(20, 29, 38, 1.0);
  static Color yellowOrWhite = Color.fromRGBO(251, 192, 45, 1.0);

  static Color listColor = darkest;

  // static Color yellow = Color.fromRGBO(251, 192, 45, 1.0);

  void nightMode(bool nightMode, String uid) {
    if (nightMode == true) {
      dark = Color.fromRGBO(36, 52, 71, 1.0);
      darkest = Color.fromRGBO(20, 29, 38, 1.0);
      blackOrWhite = Color.fromRGBO(247, 240, 231, 1.0);
      yellow = Color.fromRGBO(251, 192, 45, 1.0);
      whiteOrBlack = Colors.black;
      cardColor = dark;
      listColor = darkest;
      appBarColor = Color.fromRGBO(20, 29, 38, 1.0);
      kitGradients = [darkest, dark];
      yellowOrWhite = Color.fromRGBO(251, 192, 45, 1.0);
    } else {
      darkest = Color.fromRGBO(228, 222, 217, 1);
      dark = Color.fromRGBO(247, 240, 231, 1.0);
      blackOrWhite = Colors.black;
      // yellow = Color.fromRGBO(242, 134, 33, 1.0);
      whiteOrBlack = Color.fromRGBO(247, 240, 231, 1.0);
      listColor = Color.fromRGBO(228, 222, 217, 1);
      cardColor = listColor;
      kitGradients = [Colors.grey, Color.fromRGBO(247, 240, 231, 1.0)];
      appBarColor = yellow;
      yellowOrWhite = white;
    }
    Firestore.instance
        .document("users/$uid")
        .updateData({"nightmode": nightMode});
  }

  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),

    darkest,
    dark,
  ];
  static List<Color> kitGradients2 = [
    Colors.orange.shade800,
    Colors.pink,
  ];

  //randomcolor
  static final Random _random = new Random();

  /// Returns a random color.
  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }
}
