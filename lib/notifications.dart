import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RainNotification {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  new FlutterLocalNotificationsPlugin();

  // notification that tells the user it's going to rain that day
  Future<void> rainNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Rain Checker', 'Today is raining', platformChannelSpecifics,
        payload: 'item x');
  }

  // placeholder for testing telling the user it's not going to rain (when in use nothing will happen if there's no rain)
  Future<void> noRainNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Rain Checker', 'Today is not raining', platformChannelSpecifics,
        payload: 'item x');
  }

  RainNotification() {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
