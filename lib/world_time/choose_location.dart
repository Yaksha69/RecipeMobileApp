import 'package:flutter/material.dart';
import 'package:recipeapp/world_time/world_time_Service.dart';


class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

  List<WorldTimeService> locations = [
    WorldTimeService(location: 'Philippines', urlCont: 'Asia', urlCount: 'Manila'),
    WorldTimeService(location: 'Germany', urlCont: 'Europe', urlCount: 'Berlin'),
    WorldTimeService(location: 'Russia', urlCont: 'Europe', urlCount: 'Moscow'),
  ];

  void updateTime(index) async {
    WorldTimeService instance = locations[index];
    await instance.getTime();

    Navigator.pop(context, {
      'location': instance.location ?? '-',
      'time': instance.time ?? '-',
      'urlCont': instance.urlCont ?? '-',
      'urlCount': instance.urlCount ?? '-',
      'isDaytime': instance.isDaytime ?? false,
    });
  }

  @override
  Widget build(BuildContext context) {
    print('initstate func runs');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Choose a Location'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  updateTime(index);
                },
                title: Text(locations[index].location!),
              ),
            ),
          );
        },
      )
    );
  }
}