import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<bool> openUrl(String url) async {
    if (!url.startsWith("www")) {
      url = "www.$url";
    }
    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class TextUtils {
  static double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  static Widget markedText(String text, String pattern,
      {TextStyle? textStyle, Color? markColor, bool caseSensitive = false}) {
    markColor ??= Colors.lightBlue.withOpacity(.2);
    final TextStyle markStyle = textStyle == null
        ? TextStyle(backgroundColor: markColor)
        : textStyle.copyWith(backgroundColor: markColor);

    final List<Match> matches = caseSensitive
        ? pattern.trim().allMatches(text.trim()).toList(growable: false)
        : pattern
            .trim()
            .toLowerCase()
            .allMatches(text.trim().toLowerCase())
            .toList(growable: false);
    List<TextSpan> spans = [];

    for (int i = 0; i < matches.length; i++) {
      final Match m = matches[i];
      spans.add(TextSpan(
          text: text.substring(i == 0 ? 0 : matches[i - 1].end, m.start), style: textStyle));
      spans.add(TextSpan(text: text.substring(m.start, m.end), style: markStyle));
    }
    spans.add(TextSpan(
        text: matches.isEmpty ? text : text.substring(matches.last.end, text.length),
        style: textStyle));

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
