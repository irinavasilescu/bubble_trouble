import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final icon;

  MyButton({this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.grey[100],
          width: 50,
          height: 50,
          child: Center(child: Icon(icon)),
        ));
  }
}
