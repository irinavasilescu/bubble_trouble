import 'dart:async';

import 'package:bubble_trouble/button.dart';
import 'package:bubble_trouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// It is a stateful widget because the game will have lots of moving parts
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Player variables (for left-right movement)
  static double playerX = 0;

  // Missile variables
  double missileX = playerX;
  double missileY = 1;
  double missileHeight = 10;

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
        // do nothing
      } else {
        playerX -= 0.1;
      }

      missileX = playerX;
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 > 1) {
        // do nothing
      } else {
        playerX += 0.1;
      }

      missileX = playerX;
    });
  }

  void fireMissile() {
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (missileHeight > MediaQuery.of(context).size.height * 3/4) { // because of flex: 3
        // stop missile
        resetMissile();
        timer.cancel();
      } else {
        setState(() {
          missileHeight += 10;
        });
      }
    });
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 10;
  }

  @override
  Widget build(BuildContext context) {
    // In the column will be two expanded widgets (one on top of each other)
    // Instead of setting a fixed height for the containers, they will expand the container to fill all the space
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }

        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3, // This container takes up 75% of the space
            child: Container(
              color: Colors.pink[100],
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment(missileX, missileY),
                      child: Container(
                        width: 2,
                        height: missileHeight,
                        color: Colors.grey
                      ),
                    ),
                    MyPlayer(
                      playerX: playerX
                    )
                  ],
                )
              )
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    icon: Icons.arrow_back,
                    function: moveLeft,
                  ),
                  MyButton(
                    icon: Icons.arrow_upward,
                    function: fireMissile,
                  ),
                  MyButton(
                    icon: Icons.arrow_forward,
                    function: moveRight,
                  ),
                ]
              )
            )
          )
        ],
      ),
    );
  }
}
