import 'package:flutter/material.dart';


import 'pages/dashboard.dart';
import 'pages/list_item.dart';
import 'pages/add_recipe.dart';

void main() {
  runApp(
    MaterialApp(
      routes: {
        '/': (context) => const ListItem(),
        '/list': (context) =>  ListItem(),
        '/add': (context) => const Addrecipe(),
      },
    ),
  );
}