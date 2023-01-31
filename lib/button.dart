import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      width: 50,
      height: 50,
      child: Center(child: Icon(Icons.arrow_back)),
    );
  }
}
