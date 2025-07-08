import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTimeService {
  String? location;
  String? time;
  String? urlCont;
  String? urlCount;
  bool? isDaytime;

  WorldTimeService({this.location, this.urlCont, this.urlCount});

  Future<void> getTime() async {
    try {
      Response response = await get(
        Uri.parse('https://www.timeapi.io/api/time/current/zone?timeZone=$urlCont%2F$urlCount'),
      );
      Map data = jsonDecode(response.body);
      print(data);

      // get prot data
      String datetime = data['dateTime'];
      print(datetime);

      // create dateTime object
      DateTime now = DateTime.parse(datetime);
      print(now);

      // set
      isDaytime =  now.hour > 6 && now.hour < 9 ? true: false;
      time = DateFormat.jm().format(now);

    } catch (e) {
      print('Error: $e');
      time =  'error time di makuha';
    }
  }
}