import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:weather_app/notifications.dart';
import 'package:weather_app/weather_data.dart';
import 'package:weather_app/settings.dart';
import 'package:preferences/preferences.dart';
import 'package:weather_app/check_rain.dart';

// TODO: add push notifications to iOS

void main() async {

  // this line is required in async main() to prevent unhandled exception
  WidgetsFlutterBinding.ensureInitialized();

  // this is required to use the preferences package
  await PrefService.init(prefix: 'pref_');

  // if opening the app for the first time, set notifications as off
  PrefService.getString('notification_status') ?? PrefService.setString('notification_status', 'OFF');

  // initialise the work manager
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  runApp(MaterialApp(
    // routes for navigation
    initialRoute: '/',
    routes: {
      '/' : (context) => MyApp(),
      '/settings' : (context) => Settings(),
      '/check_rain' : (context) => CheckRain(),
    },
  ));
}

enum dayChoice {today, tomorrow}

// TODO: refactor this global mutable variable
RainNotification notifications = new RainNotification();

// Check the rain forecast and send the correct notification
void callbackDispatcher() {

  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case 'rain_notify':
        List rainCheck = await getForecast(dayChoice.today);
        if (rainCheck[0]) await notifications.rainNotification(rainCheck[1]);
        else await notifications.noRainNotification();
    }
    return Future.value(true);
  });
}

Future<List> getForecast(dayChoice day) async {

  // initialise shared preferences
  await PrefService.init();

  // get the weather forecast
  WeatherApiClient weatherClient = new WeatherApiClient(
      httpClient: http.Client());

  final WeatherForecast weather = await weatherClient.fetchWeather(getLocation());
  final List<Data> weatherData = weather.data;

  // get today and tomorrow's date
  final DateTime today = DateTime.parse(weatherData[0].timestampLocal);
  final DateTime tomorrow = today.add(Duration(days:1));

  // iterate through each data point from the API
  for (Data x in weatherData) {
    int chance = x.pop;

    // initialise the current date and time for the data set
    DateTime dataTime = DateTime.parse(x.timestampLocal);

    // ignore data if outside prescribed hours
    if (dataTime.hour < getStartTime() || dataTime.hour > getEndTime()) continue;

    // check if raining on that particular data point
    if ((day == dayChoice.today && today.day == dataTime.day) || (day == dayChoice.tomorrow && tomorrow.day == dataTime.day)){
      if (chance > getRainChance()) return [true, dataTime.hour];
    } else continue;
  }
  return [false, null];
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Rain Checker')),
          backgroundColor: Colors.teal[500],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Notifications are: ' + PrefService.getString('notification_status')),
              if (PrefService.getString('notification_status') == "OFF") RaisedButton(
                child: Text('Enable notifications'),
                onPressed: () async {

                  // calculate the initial delay required to schedule the notification properly
                  final now = DateTime.now();
                  Duration delay;
                  if (now.hour > getNotificationTime()) {
                    delay = now.difference(DateTime(now.year, now.month, now.day + 1, getNotificationTime().toInt(), 0)).abs();
                  } else {
                    delay = now.difference(DateTime(now.year, now.month, now.day, getNotificationTime().toInt(), 0)).abs();
                  }

                  print(delay);

                  // schedule a periodic notification
                  await Workmanager.registerPeriodicTask("1",
                    'rain_notify',
                    frequency: Duration(hours:3),
                    initialDelay: delay,
                  );

                  // set notifications as ON
                  setState(() {
                    PrefService.setString('notification_status', "ON");
                  });

                },
              ),
              if (PrefService.getString('notification_status') == "ON") RaisedButton(
                child: Text('Cancel notifications'),
                onPressed: () {

                  // cancel all notifications
                  Workmanager.cancelAll();

                  // set notifications as OFF
                  setState(() {
                    PrefService.setString('notification_status', "OFF");
                  });

                },
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RaisedButton(
                        child: Text('Settings'),
                        textColor: Colors.white,
                        color: Colors.teal[500],
                        onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ),
                    RaisedButton(
                      child: Text('Check Rain Now'),
                      textColor: Colors.white,
                      color: Colors.teal[500],
                      onPressed: () {
                        Navigator.pushNamed(context, '/check_rain');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}


