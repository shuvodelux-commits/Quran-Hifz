import 'package:flutter/material.dart';

import '../application/hifz_flow_composer.dart';

class HifzFlowLine extends StatelessWidget {
  const HifzFlowLine({
    super.key,
    required this.row,
    required this.rowIndex,
    required this.tokenBuilder,
  });

  final HifzFlowRow row;
  final int rowIndex;
  final Widget Function(HifzFlowToken token) tokenBuilder;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (var index = 0; index < row.tokens.length; index++) {
      if (index > 0) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(width: row.gap, height: 1),
          ),
        );
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: tokenBuilder(row.tokens[index]),
        ),
      );
    }
    return RichText(
      key: ValueKey('hifz-flow-richtext-$rowIndex'),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.start,
      text: TextSpan(children: spans),
    );
  }
}
