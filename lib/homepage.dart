import 'dart:async';
import 'dart:ui';

import 'package:bubble_trouble/ball.dart';
import 'package:bubble_trouble/button.dart';
import 'package:bubble_trouble/missile.dart';
import 'package:bubble_trouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// It is a stateful widget because the game will have lots of moving parts
class HomePage extends StatefulWidget {
    @override
    _HomePageState createState() => _HomePageState();
}

enum Direction {
    LEFT,
    RIGHT
}

class _HomePageState extends State<HomePage> {
    // Player variables (for left-right movement)
    static double playerX = 0;

    // Missile variables
    double missileX = playerX;
    double missileHeight = 0;
    bool midShot = false;

    // Ball variables
    double ballX = 0.5;
    double ballY = 1;
    var ballDirection = Direction.LEFT;

    bool pressedPlay = false;

    void startGame() {
        if (pressedPlay) {
            return;
        }

        pressedPlay = true;

        double time = 0;
        double height = 0;
        double velocity = 60; // how strong the jump is

        Timer.periodic(Duration(milliseconds: 10), (timer) {
            // quadratic equation that models a bounce (upside down parabola)
            height = -5 * time * time + velocity * time;

            // if the ball reaches the ground, reset the jump
            if (height < 0) {
                time = 0;
            }

            // update the new ball position
            setState(() {
                ballY = heightToPosition(height);
            });

            // if the ball hits the left wall, the change direction to right
            if (ballX - 0.005 < -1) {
                ballDirection = Direction.RIGHT;
                // if the ball hits the right wall, the change direction to left
            } else if (ballX + 0.005 > 1) {
                ballDirection = Direction.LEFT;
            }

            // move the ball in the correct direction
            if (ballDirection == Direction.LEFT) {
                setState(() {
                    ballX -= 0.005;
                });
            } else if (ballDirection == Direction.RIGHT) {
                setState(() {
                    ballX += 0.005;
                });
            }

            // check if ball hits the player
            if (playerDies()) {
                ballX = 5;
                timer.cancel();
                pressedPlay = false;
                _showDialog('YOU ARE DEAD!');
            }

            // keep the time going
            time += 0.1;
        });
    }

    void restartGame() {
        // close dialog
        Navigator.of(context, rootNavigator: true).pop('dialog');

        // reinitialize all variables
        playerX = 0;
        missileX = playerX;
        missileHeight = 0;
        midShot = false;
        ballX = 0.5;
        ballY = 1;
        ballDirection = Direction.LEFT;

        startGame();
    }
    
    void _showDialog(String text) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    backgroundColor: Colors.grey[700],
                    title: Center(
                        child: DefaultTextStyle(
                            child: Text(text),
                            style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'PixeloidSans')
                        )
                    ),
                    content: Container(
                        height: 50,
                        child: Center(
                            child: MyButton(
                                text: 'Restart',
                                textColor: Colors.green,
                                function: restartGame,
                            ),
                        )
                    )
                );
            }
        );
    }

    void moveLeft() {
        setState(() {
            if (playerX - 0.1 < -1) {
                // do nothing
            } else {
                playerX -= 0.1;
            }

            // adjust missile position only when the player is not in the middle of a shot
            // it won't follow us during moving, it continue shooting from the position it was fired
            if (!midShot) {
                missileX = playerX;
            }
        });
    }

    void moveRight() {
        setState(() {
            if (playerX + 0.1 > 1) {
                // do nothing
            } else {
                playerX += 0.1;
            }

            // adjust missile position only when the player is not in the middle of a shot
            // it won't follow us during moving, it continue shooting from the position it was fired
            if (!midShot) {
                missileX = playerX;
            }
        });
    }

    void fireMissile() {
        if (midShot == false) {
            Timer.periodic(Duration(milliseconds: 20), (timer) {
                // shots fired
                midShot = true;

                // missile grows until it hits the top of the screen
                setState(() {
                    missileHeight += 10;
                });

                // stop missile when it reaches the top of the screen
                if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) { // because of flex: 3
                    // stop missile
                    resetMissile();
                    timer.cancel();
                }

                // check if missile has hit the ball (top of the missile or the length of the missile touches the ball)
                // we can't do ballX == missileX because of how doubles work,
                // so we'll just check there is a very small error between them
                if (ballY > heightToPosition(missileHeight) && (ballX - missileX).abs() < 0.03) {
                    resetMissile();
                    ballX = 5;
                    timer.cancel();
                    pressedPlay = false;
                    _showDialog('YOU WON!');
                }
            });
        }
    }

    void resetMissile() {
        missileX = playerX;
        missileHeight = 0;
        midShot = false;
    }

    // converts height into a coordinate
    double heightToPosition(double height) {
        double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
        double position = 1 - 2 * height / totalHeight;
        return position;
    }

    bool playerDies() {
        // if the ball position and the player position are the same, then the player dies
        if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
            return true;
        } else {
            return false;
        }
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
                }
                
                if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                    moveRight();
                }

                if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                    fireMissile();
                }

                if (event.isKeyPressed(LogicalKeyboardKey.space)) {
                    startGame();
                }
            },
            child: Column(
                children: [
                    Expanded(
                        flex: 3, // This container takes up 75% of the space
                        child: Container(
                            color: Colors.blue[900],
                            child: Center(
                                child: Stack(
                                    children: [
                                        Center(
                                            child: Container(
                                                height: 300,
                                                child: Column(
                                                    children: [
                                                        Container(
                                                            child: DefaultTextStyle(
                                                                child: Text('BUBBLE TROUBLE'),
                                                                style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'PixeloidSans')
                                                            )
                                                        ),
                                                        Container(
                                                            child: Container(
                                                                width: 85,
                                                                height: 75,
                                                                margin: EdgeInsets.symmetric(vertical: 10),
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image: AssetImage('assets/heart.png'),
                                                                        fit: BoxFit.fill
                                                                    )
                                                                )
                                                            )
                                                        ),
                                                        Container(
                                                            child: DefaultTextStyle(
                                                                child: Text('FLUTTER'),
                                                                style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'PixeloidSans')
                                                            )
                                                        ),
                                                    ],
                                              ),
                                            )
                                        ),
                                        MyBall(ballX: ballX, ballY: ballY),
                                        MyMissile(height: missileHeight, missileX: missileX),
                                        MyPlayer(playerX: playerX)
                                    ]
                                )
                            )
                        ),
                    ),
                    Expanded(
                        child: Container(
                            color: Colors.green,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                    MyButton(
                                        icon: Icons.play_arrow,
                                        function: startGame,
                                    ),
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
