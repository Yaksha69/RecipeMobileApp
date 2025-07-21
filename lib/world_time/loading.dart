// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'world_time_Service.dart';


class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  String time = 'loading';

  void setupWorldTime() async {
    WorldTimeService instance = WorldTimeService(location: 'Manila', urlCont: 'Asia', urlCount: 'Manila');
    await instance.getTime();
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'location': instance.location,
      'time': instance.time,
      'urlCont': instance.urlCont,
      'urlCount': instance.urlCount,
      'isDaytime': instance.isDaytime,
    });
  }

  @override
  void initState() {
    super.initState();
    setupWorldTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Text('loading'),
      )
    );
  }
}