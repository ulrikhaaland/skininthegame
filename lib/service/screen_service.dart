import 'package:flutter/material.dart';

class ScreenService {

  ScreenService() {
    print('ScreenService: constructor');
  }

  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getPortraitHeight(BuildContext context) {
    if (isLandscape(context))
      return MediaQuery.of(context).size.width;
    else
      return MediaQuery.of(context).size.height;
  }

  double getHeightByPercentage(BuildContext context, double percentage) {
    /// Might have passed 0.1 = 10% for instance
    if (percentage < 1.0) {
      percentage = percentage * 100;
    }

    return getHeight(context) * (percentage / 100);
  }

  double getPortraitHeightByPercentage(
      BuildContext context, double percentage) {
    /// Might have passed 0.1 = 10% for instance
    if (percentage < 1.0) {
      percentage = percentage * 100;
    }

    if (isLandscape(context))
      return MediaQuery.of(context).size.width * (percentage / 100);
    else
      return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getPortraitWidth(BuildContext context) {
    if (isLandscape(context))
      return MediaQuery.of(context).size.height;
    else
      return MediaQuery.of(context).size.width;
  }

  double getWidthByPercentage(BuildContext context, double percentage) {
    /// Might have passed 0.1 = 10% for instance
    if (percentage < 1.0) {
      percentage = percentage * 100;
    }

    return getWidth(context) * (percentage / 100);
  }

  double getPortraitWidthByPercentage(BuildContext context, double percentage) {
    /// Might have passed 0.1 = 10% for instance
    if (percentage < 1.0) {
      percentage = percentage * 100;
    }
    if (isLandscape(context))
      return MediaQuery.of(context).size.height * (percentage / 100);
    else
      return MediaQuery.of(context).size.width * (percentage / 100);
  }

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}