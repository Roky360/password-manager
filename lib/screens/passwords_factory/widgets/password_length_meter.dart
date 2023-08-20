import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PasswordLengthMeter extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final Color color;
  final void Function(int)? onChanged;

  const PasswordLengthMeter({
    super.key,
    this.minValue = 1,
    this.maxValue = 16,
    required this.value,
    this.color = Colors.blue,
    this.onChanged,
  });

  @override
  State<PasswordLengthMeter> createState() => _PasswordLengthMeterState();
}

class _PasswordLengthMeterState extends State<PasswordLengthMeter> {
  late final int minValue;
  late final int maxValue;
  late int value;
  late final Color color;
  late final void Function(int)? onChanged;

  final double barHeight = 15;

  @override
  void initState() {
    super.initState();

    minValue = widget.minValue;
    maxValue = widget.maxValue;
    value = widget.value.clamp(minValue, maxValue);
    color = widget.color;
    onChanged = widget.onChanged;
  }

  @override
  Widget build(BuildContext context) {
    return SfSliderTheme(
      data: SfSliderThemeData(
        thumbColor: Colors.white,
        tooltipBackgroundColor: color,
        thumbRadius: barHeight * .7,
        inactiveTrackHeight: barHeight,
        activeTrackHeight: barHeight,
        inactiveTrackColor: Colors.blueGrey.shade50,
        overlayColor: color.withOpacity(.15),
        activeTrackColor: color.withOpacity(.7),
      ),
      child: SfSlider(
        min: minValue,
        max: maxValue,
        value: value,
        stepSize: 1,
        tooltipShape: const SfPaddleTooltipShape(),
        enableTooltip: true,
        thumbIcon: Center(
            child: Text(
          value.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: .8),
        )),
        onChanged: (val) {
          val = val.toInt();
          setState(() => value = val);
          onChanged?.call(val);
        },
      ),
    );
  }
}
