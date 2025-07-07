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
    WorldTimeService instance = WorldTimeService(location: 'India', urlCont: 'Asia', urlCount: 'Manila');
    await instance.getTime();
    print(instance.time);
    setState(() {
      time = instance.time ?? 'No time available';
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
        child: Text(time),
      )
    );
  }
}