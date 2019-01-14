import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    this.key,
    this.text,
    this.onPressed,
    this.color,
  }) : super(key: key);
  final Key key;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: BoxConstraints(minWidth: 600.0, minHeight: 50.0),
      child: new RaisedButton(
          child: new Text(text,
              style: new TextStyle(color: Colors.black, fontSize: 20.0)),
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          color: color,
          textColor: Colors.black,
          elevation: 8.0,
          onPressed: onPressed),
    );
  }
}
