import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RainNotification {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  new FlutterLocalNotificationsPlugin();

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

  Future<void> notifScheduled() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Rain Checker', 'Notification has been scheduled', platformChannelSpecifics,
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

//  Future<void> scheduledNotification2() async {
//    var scheduledNotificationDateTime =
//    DateTime.now().add(Duration(seconds: 5));
//    var androidPlatformChannelSpecifics =
//    AndroidNotificationDetails('your other channel id',
//        'your other channel name', 'your other channel description');
//    var iOSPlatformChannelSpecifics =
//    IOSNotificationDetails();
//    NotificationDetails platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.schedule(
//        0,
//        'its not raining',
//        'its not raining',
//        scheduledNotificationDateTime,
//        platformChannelSpecifics);
//  }


//  Future onSelectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('Notification paylood: $payload');
//    }
//  }
//
//  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
//    await showDialog(
//        context: context,
//        builder: (BuildContext context)=>CupertinoAlertDialog(
//            title:  Text(title),
//            content: Text(body),
//            actions: <Widget>[
//              CupertinoDialogAction(
//                  isDefaultAction: true,
//                  child: Text('Ok')
//              )
//            ]
//        )
//    );
//  }


//  Future<void> _scheduledNotification() async {
//    var time = Time(9, 0, 0);
//    var androidPlatformChannelSpecifics =
//    AndroidNotificationDetails('repeatDailyAtTime channel id',
//        'repeatDailyAtTime channel name', 'repeatDailyAtTime description');
//    var iOSPlatformChannelSpecifics =
//    IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.showDailyAtTime(
//        0,
//        'show daily title',
//        'Daily notification shown at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
//        time,
//        platformChannelSpecifics);
//  }

  }

