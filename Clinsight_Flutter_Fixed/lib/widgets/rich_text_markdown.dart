import 'package:flutter/material.dart';

/// Renders text with **bold** markdown as RichText.
class RichTextMarkdown extends StatelessWidget {
  const RichTextMarkdown({
    super.key,
    required this.data,
    this.style,
    this.boldStyle,
  });

  final String data;
  final TextStyle? style;
  final TextStyle? boldStyle;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ??
        DefaultTextStyle.of(context).style.copyWith(height: 1.5);
    final bold = boldStyle ??
        defaultStyle.copyWith(fontWeight: FontWeight.w700);

    return RichText(
      text: _parseMarkdownBold(data, defaultStyle, bold),
    );
  }

  static InlineSpan _parseMarkdownBold(
    String text,
    TextStyle normal,
    TextStyle bold,
  ) {
    final spans = <InlineSpan>[];
    int i = 0;
    while (i < text.length) {
      if (i + 1 < text.length && text[i] == '*' && text[i + 1] == '*') {
        final end = text.indexOf('**', i + 2);
        if (end != -1) {
          spans.add(TextSpan(
            text: text.substring(i + 2, end),
            style: bold,
          ));
          i = end + 2;
          continue;
        }
      }
      final nextBold = text.indexOf('**', i);
      if (nextBold == -1) {
        spans.add(TextSpan(text: text.substring(i), style: normal));
        break;
      }
      spans.add(TextSpan(text: text.substring(i, nextBold), style: normal));
      i = nextBold;
    }
    return TextSpan(children: spans);
  }
}
