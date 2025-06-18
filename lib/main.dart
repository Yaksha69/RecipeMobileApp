import 'package:flutter/material.dart';

void main() {
  runApp( MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Recipe App'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Text('gitnang text are', style: TextStyle(
              fontSize: 24,
              foreground: Paint()
                ..shader = LinearGradient(colors: [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                ]).createShader(Rect.fromLTWH(150.0, 10.0, 200.0, 70.0)),
              fontWeight: FontWeight.bold,
              decorationColor: Colors.red,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.wavy,
                
            ))
          ],
        )
      ),
      )
    ),
  );
}

