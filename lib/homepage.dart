import 'dart:async';

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
    double missileHeight = 10;
    bool midShot = false;

    // Ball variables
    double ballX = 0.5;
    double ballY = 1;
    var ballDirection = Direction.LEFT;

    void startGame() {
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

            // keep the time going
            time += 0.1;
        });
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
                }
            });
        }
    }

    void resetMissile() {
        missileX = playerX;
        missileHeight = 10;
        midShot = false;
    }

    // converts height into a coordinate
    double heightToPosition(double height) {
        double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
        double position = 1 - 2 * height / totalHeight;
        return position;
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
                            color: Colors.grey,
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
