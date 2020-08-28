import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/main.dart';
import 'package:weather_app/settings.dart';

// page for allowing the user to get the rain forecast for the current day or the next day

class CheckRain extends StatefulWidget {
  @override
  _CheckRainState createState() => _CheckRainState();
}

class _CheckRainState extends State<CheckRain> {

  String forecast = "";

  Future<void> showForecast(dayChoice day) async {
    // get the weather forecast
    WeatherApiClient weatherClient = new WeatherApiClient(
        httpClient: http.Client());

    final WeatherForecast weatherForecast = await weatherClient
        .fetchWeather(getLocation());
    final List<Data> weatherData = weatherForecast.data;

    // get today's date
    final DateTime today = DateTime.parse(weatherData[0].timestampLocal);
    final DateTime tomorrow = today.add(Duration(days: 1));

    bool raining = false;
    forecast = "";

    for (Data x in weatherData) {
      int chance = x.pop;

      // initialise the current date and time for the data set
      DateTime dataTime = DateTime.parse(x.timestampLocal);

      // ignore data if outside prescribed hours
      if (dataTime.hour < getStartTime() ||
          dataTime.hour > getEndTime()) continue;

      // verify the data point is from either today or tomorrow and update the forecast accordingly
      if ((day == dayChoice.today && today.day == dataTime.day) ||
          (day == dayChoice.tomorrow && tomorrow.day == dataTime.day)) {
        forecast += 'There is a $chance% chance of rain ' +
            day.toString().substring(day.toString().indexOf('.') + 1) +
            ' at ' + doubleToTimeString(dataTime.hour) + '\n';
        if (chance > getRainChance()) raining = true;
      } else
        continue;
    }

    // if it's not raining overwrite the message to say it's not raining today
    if (!raining) {
      forecast = 'There is a 0% chance of rain ' +
          day.toString().substring(day.toString().indexOf('.') + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[500],
        title: Text('Check rain now'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      await showForecast(dayChoice.today);
                      setState(() {});
                    },
                    child: Text('Today'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await showForecast(dayChoice.tomorrow);
                      setState(() {});
                    },
                    child: Text('Tomorrow'),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(forecast)
              ,
            ),
            SizedBox(

            ),
          ],
        ),
      ),
    );
  }
}
