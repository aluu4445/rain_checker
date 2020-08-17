import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/main.dart' as main;

// page for allowing the user to get the rain forecast for the current day or the next day

class CheckRain extends StatefulWidget {
  @override
  _CheckRainState createState() => _CheckRainState();
}

class _CheckRainState extends State<CheckRain> {
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
                      await main.getTodayForecast();
                      setState(() {});
                    },
                    child: Text('Today'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await main.getTomorrowForecast();
                      setState(() {});
                    },
                    child: Text('Tomorrow'),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(main.forecast)
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
