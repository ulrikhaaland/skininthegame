import 'package:flutter/material.dart';
import '../service/service_provider.dart';
import 'package:yadda/utils/uidata.dart';
import 'nav_helper_text.dart';

class NavAppBar extends StatelessWidget {
  NavAppBar(
      {@required this.navItemList,
      this.title,
      this.key,
      this.actions,
      this.titleText})
      : super(key: key);
  final Key key;
  final Widget title;
  final String titleText;
  final List<String> navItemList;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
          actions: actions,
          elevation: 0,
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          backgroundColor: UIData.appBarColor,
          title: titleWidget(),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: addNav(this.navItemList, context))
      ],
    );
  }

  Widget titleWidget() {
    if (title == null) {
      return Text(titleText,
          style: new TextStyle(
              fontSize: UIData.fontSize24, color: UIData.blackOrWhite));
    } else {
      return title;
    }
  }
}
