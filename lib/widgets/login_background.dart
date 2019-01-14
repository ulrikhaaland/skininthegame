import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';

class LoginBackground extends StatelessWidget {
  final showIcon;
  final image;
  LoginBackground({this.showIcon = true, this.image});

  Widget topHalf(BuildContext context) {
    return new Flexible(
      flex: 10000,
      child: new Container(
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          colors: UIData.kitGradients,
        )),
      ),
    );
  }

  final bottomHalf = new Flexible(
    flex: 3,
    child: new Container(),
  );

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[topHalf(context), bottomHalf],
    );
  }
}
