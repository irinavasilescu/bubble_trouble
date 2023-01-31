import 'package:bubble_trouble/button.dart';
import 'package:flutter/material.dart';

// It is a stateful widget because the game will have lots of moving parts
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // In the column will be two expanded widgets (one on top of each other)
    // Instead of setting a fixed height for the containers, they will expand the container to fill all the space
    return Column(
      children: [
        Expanded(
            flex: 3, // This container takes up 75% of the space
            child: Container(color: Colors.pink[100])),
        Expanded(
            child: Container(
                color: Colors.grey,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(icon: Icons.arrow_back),
                      MyButton(icon: Icons.arrow_upward),
                      MyButton(icon: Icons.arrow_forward),
                    ])))
      ],
    );
  }
}
