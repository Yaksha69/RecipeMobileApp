import 'package:flutter/material.dart';

import 'world_time/home.dart';
import 'world_time/loading.dart';
import 'world_time/choose_location.dart';

void main() {
  runApp(
    MaterialApp(
      routes: {
        '/': (context) => const Loading(),
        'home': (context) => const Home(),
        '/location': (context) => const ChooseLocation(),
      },
    ),
  );
}
