import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map data = {};

  @override
  Widget build(BuildContext context) {
    try {
      data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    } catch (e) {
      data = {
        'location': 'sa langit',
        'time': 'relapse',
      };
    }

    String? bgImage = (data['isDaytime'] == true) ? 'day.jpg' : 'night.jpg';
    Color? bgcolor = (data['isDaytime'] == true) ? Colors.blue : Colors.indigo[700];

    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/$bgImage'),
              fit: BoxFit.cover,
            )
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    dynamic result = await Navigator.pushNamed(context, '/location');
                    if (result != null) {
                      setState(() {
                        data = {
                          'location': result['location'] ?? 'Unknown Location',
                          'time': result['time'] ?? 'Loading...',
                          'urlCont': result['urlCont'],
                          'urlCount': result['urlCount'],
                          'isDaytime': result['isDaytime'] ?? false,
                        };
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  icon: Icon(Icons.edit_location, color: const Color.fromARGB(255, 255, 255, 255)),
                  label: Text('Edit Location', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)))
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['location'] ?? 'Unknown Location',
                      style: TextStyle(
                        fontSize: 28,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0,),
                Text(
                  data['time'] ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 60.0,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}