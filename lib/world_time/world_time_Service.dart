import 'package:http/http.dart';
import 'dart:convert';

class WorldTimeService {
  String? location;
  String? time;
  String? urlCont;
  String? urlCount;

  WorldTimeService({this.location, this.urlCont, this.urlCount});

  Future <void> getTime() async {
  Response response = await get(
    Uri.parse('https://www.timeapi.io/api/time/current/zone?timeZone=$urlCont%2F$urlCount'),
    );
    Map data = jsonDecode(response.body);
    print(data);

    // get prot data
    String datetime = data['dateTime'];
    print(datetime);

    // create dateTIme object
    DateTime now = DateTime.parse(datetime);
    print(now);

    //set
    time = now.toString();
  }
}