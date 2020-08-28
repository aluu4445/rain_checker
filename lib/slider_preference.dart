import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

// Mirrors the widgets in the Preferences package but for sliders instead

class SliderPreference extends StatefulWidget {
  final String title;
  final String desc;
  final String localKey;
  final double defaultVal;

  final double value;

  final int divisions;
  final double min;
  final double max;

  final String label;

  final Function onChanged;

  final bool disabled;

  SliderPreference(
    this.title,
    this.localKey, {
    this.desc,
    this.value,
    @required this.defaultVal,
    @required this.divisions,
    @required this.min,
    @required this.max,
    this.label,
    this.onChanged,
    this.disabled = false,
  });

  _SliderPreferenceState createState() => _SliderPreferenceState();
}

class _SliderPreferenceState extends State<SliderPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.get(widget.localKey) == null) {
      PrefService.setDefaultValues({widget.localKey: widget.defaultVal});
    }
  }

  @override
  Widget build(BuildContext context) {
    double value;
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

    return Slider(
        // retrieves the value from a unique key
        value: PrefService.getDouble(widget.localKey) ?? widget.defaultVal,
        divisions: widget.divisions,
        min: widget.min,
        max: widget.max,
        label: widget.label,
        activeColor: Colors.teal[500],
        inactiveColor: Colors.teal[100],
        onChanged: widget.disabled
            ? null
            : (double val) async {
                this.setState(
                    // saves the value under a unique key
                    () => PrefService.setDouble(widget.localKey, val));
                if (widget.onChanged != null) widget.onChanged(val);
              });

  }
}
