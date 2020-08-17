import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class RangeSliderPreference extends StatefulWidget {
  final String title;
  final String desc;
  final String localKey;
  final RangeValues defaultVal;

  final RangeValues values;

  final int divisions;
  final double min;
  final double max;
  final RangeLabels labels;

  final Function onChanged;

  final bool disabled;

  RangeSliderPreference(
    this.title,
    this.localKey, {
    this.desc,
    @required this.defaultVal,
    @required this.values,
    @required this.divisions,
    @required this.min,
    @required this.max,
    this.labels,
    this.onChanged,
    this.disabled = false,
  });

  _RangeSliderPreferenceState createState() => _RangeSliderPreferenceState();
}

class _RangeSliderPreferenceState extends State<RangeSliderPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.get(widget.localKey) == null) {
      PrefService.setDefaultValues({
        widget.localKey + '1': widget.defaultVal.start,
        widget.localKey + '2': widget.defaultVal.end
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    RangeValues value;
    try {
      value = PrefService.get(widget.localKey) ?? widget.defaultVal;
    } on TypeError catch (e) {
      value = widget.defaultVal;
      assert(() {
        throw FlutterError('''$e
The PrefService value for "${widget.localKey}" is not the right type (${PrefService.get(widget.localKey)}).
In release mode, the default value ($value) will silently be used.
''');
      }());
    }

    return RangeSlider(
      values: RangeValues(
            PrefService.getDouble(widget.localKey + '1'),
            PrefService.getDouble(widget.localKey + '2'),
          ) ??
          widget.defaultVal,
      divisions: widget.divisions,
      min: widget.min,
      max: widget.max,
      labels: widget.labels,
      activeColor: Colors.teal[500],
      inactiveColor: Colors.teal[100],
      onChanged: widget.disabled
          ? null
          : (RangeValues vals) async {
              this.setState(
                  // saves the value under a unique key
                  () {
                PrefService.setDouble(widget.localKey + '1', vals.start);
                PrefService.setDouble(widget.localKey + '2', vals.end);
              });
              if (widget.onChanged != null) widget.onChanged(vals);
            },
    );

//  return ListTile(
//  title: Text(widget.title),
//  subtitle: widget.desc == null ? null : Text(widget.desc),
//  trailing: Slider(
//  value: widget.value ?? widget.defaultVal,
//  divisions: widget.divisions,
//  min: widget.min,
//  max: widget.max,
//  label: widget.label,
////        onChanged: widget.disabled
////            ? null
////            : (newVal) async {
////          onChanged(newVal);
////        },
//  ),
//  );
//}
  }
}
