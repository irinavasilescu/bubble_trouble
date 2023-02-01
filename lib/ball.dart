import 'package:flutter/material.dart';

class MyBall extends StatelessWidget {
    final double ballX;
    final double ballY;

    MyBall({required this.ballX, required this.ballY});

    @override
    Widget build(BuildContext context) {
        return Container(
            alignment: Alignment(ballX, ballY),
            child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/planet.png'),
                        fit: BoxFit.fill
                    )
                )
            ),
        );
    }
}
