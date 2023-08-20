import 'dart:math';

import 'package:zxcvbn/zxcvbn.dart';

class PasswordStrengthCheckerService {
  static final PasswordStrengthCheckerService _checkerService = PasswordStrengthCheckerService._();

  PasswordStrengthCheckerService._();

  factory PasswordStrengthCheckerService() => _checkerService;

  /* Fields */
  final Zxcvbn zxcvbn = Zxcvbn();

  Result checkPassword(String password, {List<String> userInputs = const []}) {
    final res = zxcvbn.evaluate(password, userInputs: userInputs);
    // print(res.calc_time);
    // print(res.crack_times_display);
    // print(res.guesses);
    // print(res.score);
    // final feed = res.feedback;
    // print(feed.warning);
    // if (feed.suggestions != null) {
    //   for (final f in feed.suggestions!) {
    //     print("suggestion: $f");
    //   }
    // }

    res.score = _guessesToScore(res.guesses);
    return res;
  }

  static double _guessesToScore(int guesses) {
    const DELTA = 5;
    if (guesses < 1e3 + DELTA) {
      return 1;
    } else if (guesses < 1e4 + DELTA) {
      return 2;

    } else if (guesses < pow(10, 4.5) + DELTA) {
      return 3;
    } else if (guesses < 1e5 + DELTA) {
      return 4;

    } else if (guesses < 1e6 + DELTA) {
      return 5;
    } else if (guesses < 1e7 + DELTA) {
      return 6;

    } else if (guesses < 1e8 + DELTA) {
      return 7;
    } else if (guesses < 1e9 + DELTA) {
      return 8;

    } else if (guesses < 1e10 + DELTA) {
      return 9;
    } else {
      return 10;
    }
  }
}
