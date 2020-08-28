import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:weather_app/slider_preference.dart';
import 'package:weather_app/range_slider_preference.dart';
import 'package:weather_app/keys.dart';

// TODO: let the user give permission to user their current location with geolocator

String getLocation() => PrefService.getString('location_name') ?? 'Sydney, Australia';
double getRainChance() => PrefService.getDouble('rain_chance') ?? 0;
double getStartTime() => PrefService.getDouble('active_time' + '1') ?? 7;
double getEndTime() => PrefService.getDouble('active_time' + '2') ?? 19;
double getNotificationTime() => PrefService.getDouble('notification_time') ?? 0;


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  String location;
  double rainChance;
  double startTime;
  double endTime;
  double notificationTime;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.teal[500],
      ),
      body: Theme(
        data: ThemeData(
          accentColor: Colors.teal[500],
        ),
        child: PreferencePage([
          PreferenceTitle('Location'),
          ListTile(
            title: Text('Location selected: ' + getLocation()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: RaisedButton(
              child: Text('Select your location'),

              onPressed: () async {
                Prediction p = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: kGoogleApiKey,
                  mode: Mode.overlay, // Mode.fullscreen
                  language: "en",
                  types: ["(cities)"],
//                  components: [new Component(Component.country, "en")]
                );
                setState(() {
                  PrefService.setString('location_name', p.description);
                });
              },
            ),
          ),
          PreferenceTitle('Rain Chance'),
          ListTile(
            title: Text('Selected: ' + getRainChance().toStringAsFixed(0) + '%'),
          ),
          SliderPreference(
            'Rain Chance',
            'rain_chance',
            divisions: 10,
            min: 0,
            max: 100,
            defaultVal: 0,
            label: getRainChance().toStringAsFixed(0) + '%',
            onChanged: (value) {
              setState(() {
                rainChance = value;
              });
            },
          ),

          PreferenceTitle('Active Time'),
          ListTile(
              title: Text('Start Time: ' +
                  doubleToTimeString(
                      getStartTime()) +
                  "       " +
                  'End Time: ' +
                  doubleToTimeString(
                      getEndTime()))),
          RangeSliderPreference(
            'Active Time',
            'active_time',
            divisions: 23,
            min: 0,
            max: 23,
            defaultVal: RangeValues(7,19),
            labels: RangeLabels(
                doubleToTimeString(getStartTime()),
                doubleToTimeString(getEndTime())
            ),
            onChanged: (RangeValues values) {
              setState(() {
                 startTime = values.start;
                 endTime = values.end;
              });
            },
    ),

          PreferenceTitle('Notification Time'),
          ListTile(
            title: Text('Notification Time: ' + doubleToTimeString(getNotificationTime())),

          ),
          SliderPreference(
            'Notification Time',
            'notification_time',
            divisions: 23,
            defaultVal: 0,
            min: 0,
            max: 23,
            label: doubleToTimeString(getNotificationTime()),
            onChanged: (value) {
              setState(() {
                notificationTime = value;
              });
            },
          ),
        ]),
      ),
    );
  }
}

doubleToTimeString(value) {
  if (value == 0 || value == 24) return '12am';
  else if (value == 12) return '12pm';
  else if (value > 12) {
    value = value % 12;
    return value.toStringAsFixed(0) + 'pm';
  } else {
    return value.toStringAsFixed(0) + 'am';
  }
}

