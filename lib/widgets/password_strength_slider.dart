import 'package:flutter/material.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/utils/password_utils.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PasswordStrengthSlider extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double value;
  final double trackHeight;

  late PasswordStrength _strength;
  final bool _isCompact;
  final bool showDescriptiveScore;

  PasswordStrengthSlider({
    super.key,
    this.minValue = 1,
    this.maxValue = 10,
    required this.value,
    this.showDescriptiveScore = true,
    this.trackHeight = 15,
  }) : _isCompact = false;

  PasswordStrengthSlider.compact({
    super.key,
    this.minValue = 1,
    this.maxValue = 10,
    required this.value,
    this.showDescriptiveScore = false,
    this.trackHeight = 10,
  }) : _isCompact = true;

  PasswordStrength getValueColor() {
    double fraction = value / (maxValue - minValue + 1);
    if (fraction <= .2) {
      return PasswordStrength.very_weak;
    } else if (fraction <= .4) {
      return PasswordStrength.weak;
    } else if (fraction <= .6) {
      return PasswordStrength.ok;
    } else if (fraction <= .8) {
      return PasswordStrength.good;
    } else {
      return PasswordStrength.strong;
    }
  }

  @override
  Widget build(BuildContext context) {
    _strength = getValueColor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SfSliderTheme(
          data: SfSliderThemeData(
            tooltipBackgroundColor: _strength.toColor(),
            disabledThumbColor: _strength.toColor(),
            thumbRadius: trackHeight / 2,
            inactiveTrackHeight: trackHeight,
            activeTrackHeight: trackHeight,
            disabledInactiveTrackColor: Colors.blueGrey.shade100,
            disabledActiveTrackColor: _strength.toColor()!.withOpacity(.5),
          ),
          child: SfSlider(
            min: minValue,
            max: maxValue,
            value: value,
            onChanged: null,
            tooltipShape: const SfPaddleTooltipShape(),
            shouldAlwaysShowTooltip: !_isCompact,
          ),
        ),
        Visibility(
          visible: showDescriptiveScore,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: pageMargin),
              child: Text(
                _strength.stringFormat(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: _strength.toColor()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
