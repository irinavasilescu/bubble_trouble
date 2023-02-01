import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
    final icon;
    final text;
    final textColor;
    final function;

    MyButton({this.icon, this.text, this.textColor, this.function});

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: function,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: this.icon != null
                ? Container(
                    color: Colors.grey[100],
                    width: 50,
                    height: 50,
                    child: Center(child: Icon(icon)),
                )
                : DefaultTextStyle(
                    child: Text(text),
                    style: TextStyle(color: textColor, fontSize: 20, fontFamily: 'PixeloidSans')
                )
            )
        );
    }
}
