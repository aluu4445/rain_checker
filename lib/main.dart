import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:weather_app/notifications.dart';
import 'package:weather_app/weather_data.dart';
import 'package:weather_app/settings.dart' as settings;
import 'package:preferences/preferences.dart';
import 'package:weather_app/check_rain.dart' as checkRain;
import 'package:weather_app/keys.dart' as keys;


// TODO: add push notifications to iOS
const weatherAPIKey = keys.weatherAPIKey;

const rainNotify = "rainNotify";
bool rainCheck = false;

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
      '/settings' : (context) => settings.Settings(),
      '/check_rain' : (context) => checkRain.CheckRain(),
    },
  ));
}

RainNotification notif = new RainNotification();

// Check the rain forecast and send the correct notification
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case rainNotify:
        print("Executing background task");
        await getTodayForecast();
        if (rainCheck) await notif.rainNotification();
        else await notif.noRainNotification();
    }
    return Future.value(true);
  });
}

WeatherRepository test = new WeatherRepository(
    weatherApiClient: WeatherApiClient(httpClient: http.Client()));

String forecast = "";

Future<void> getTodayForecast() async {

  await PrefService.init();

  // get the weather forecast
  final WeatherForecast weather = await test.getWeather(settings.getLocation());
  final List<Data> weatherData = weather.data;

  // get today's date
  final String today = weatherData[0].timestampLocal.substring(0, 10);

  forecast = "";
  bool raining = false;
  for (Data x in weatherData) {
    int chance = x.pop;

    // initialise the current date and time for the data set
    String timestamp = x.timestampLocal;
    String date = timestamp.substring(0, 10);
    String rainTime = timestamp.substring(11,16);
    String hour = rainTime.substring(0,2);

    // ignore data point if outside prescribed hours
    if (int.parse(hour) < settings.getStartTime() || int.parse(hour) > settings.getEndTime()) continue;

    // only look at data from today
    if (date != today) break;

    // show the chance of rain at every hour
    forecast += 'There is a $chance% chance of rain today at $rainTime\n';
    // TODO: add a graphical view of the daily rain chance
    if (chance > settings.getRainChance()) raining = true;
  }

  rainCheck = true;

  // if it's not raining overwrite the message to say it's not raining today
  if (!raining) {
    if (settings.getRainChance() == 0) forecast = 'There is a 0% chance of rain today';
    else forecast = 'There is a <' + settings.getRainChance().toStringAsFixed(0) + '% chance of rain today';
    rainCheck = false;
  }

  print(rainCheck);
}

Future<void> getTomorrowForecast() async {
  // get the weather forecast
  final WeatherForecast weather = await test.getWeather(settings.getLocation());
  final List<Data> weatherData = weather.data;

  // get today's date
  final String today = weatherData[0].timestampLocal.substring(0, 10);

  // update the rain forecast and show a corresponding message
  forecast = "";
  bool raining = false;
  int counter = 0;
  for (Data x in weatherData) {
    int chance = x.pop;

    // initialise the current date and time for the data set
    String timestamp = x.timestampLocal;
    String date = timestamp.substring(0, 10);
    String rainTime = timestamp.substring(11, 16);
    String hour = rainTime.substring(0, 2);

    // only look at data from tomorrow
    if (date == today) continue;

    // keep track of how many hours of tomorrow we've gone through
    counter++;

    // ignore data point if outside prescribed hours and if not tomorrow
    if (int.parse(hour) < settings.getStartTime() || int.parse(hour) > settings.getEndTime() || counter >= 24) continue;

    // check if it's raining
    if (chance > settings.getRainChance()) raining = true;

    // show the chance of rain at every hour
    forecast += 'There is a $chance% chance of rain tomorrow at $rainTime\n';
    // TODO: add a graphical view of the daily rain chance
    if (chance > settings.getRainChance()) raining = true;
  }

  // if it's not raining overwrite the message to say it's not raining today
  if (!raining) {
    if (settings.getRainChance() == 0) forecast = 'There is a 0% chance of rain tomorrow';
    else forecast = 'There is a <' + settings.getRainChance().toStringAsFixed(0) + '% chance of rain tomorrow';
  }

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
                  if (now.hour > settings.getNotificationTime()) {
                    delay = now.difference(DateTime(now.year, now.month, now.day + 1, settings.getNotificationTime().toInt(), 0)).abs();
                  } else {
                    delay = now.difference(DateTime(now.year, now.month, now.day, settings.getNotificationTime().toInt(), 0)).abs();
                  }

                  // schedule a periodic notification
                  await Workmanager.registerPeriodicTask("1",
                    rainNotify,
                    frequency: Duration(days:1),
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

class WeatherApiClient {
  final http.Client httpClient;

  // constructor
  WeatherApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future<WeatherForecast> fetchWeather(String city) async {
    final weatherUrl =
        'https://api.weatherbit.io/v2.0/forecast/hourly?city=$city&key=$weatherAPIKey';
    final weatherResponse = await this.httpClient.get(weatherUrl);
    if (weatherResponse.statusCode != 200) {
      throw Exception('error getting weather for location');
    }

    final weatherJson = jsonDecode(weatherResponse.body);
    return WeatherForecast.fromJson(weatherJson);
  }
}

class WeatherRepository {
  final WeatherApiClient weatherApiClient;

  WeatherRepository({@required this.weatherApiClient})
      : assert(weatherApiClient != null);

  Future<WeatherForecast> getWeather(String city) async {
    return weatherApiClient.fetchWeather(city);
  }
}

