import 'package:flutter/material.dart';

void main() {
  runApp( MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Recipe App'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children:[
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                                  foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    Colors.red, // dark gray
                    Colors.green, // medium gray
                    Colors.blue, // light gray
                  ],
                ).createShader(Rect.fromLTWH(5.0, 0.0, 200.0, 70.0)),
                    
                  ),
                ),
                Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    'duon'
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              children: [
                Text(
                  'Age',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue
                  ),
                ),
                Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    'sa gitna'
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB( 1, 2, 3, 4),
            child: Row(
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  color: Colors.lightBlueAccent,
                  child: Text(
                    'sa ilalim'
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      )
    ),
  );
}

