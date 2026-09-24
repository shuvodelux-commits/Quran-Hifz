import 'package:flutter/material.dart';

/// A quiet edge scrollbar that enters numbered scrub mode on long press.
class NumberQuickScrollRail extends StatefulWidget {
  const NumberQuickScrollRail({
    super.key,
    required this.count,
    required this.semanticLabel,
    required this.onPreview,
    required this.onSelected,
    this.current,
  }) : assert(count > 0);

  final int count;
  final String semanticLabel;
  final ValueChanged<int> onPreview;
  final ValueChanged<int> onSelected;
  final int? current;

  @override
  State<NumberQuickScrollRail> createState() => _NumberQuickScrollRailState();
}

class _NumberQuickScrollRailState extends State<NumberQuickScrollRail> {
  int? _preview;
  int? _committed;
  double _previewY = 0;

  @override
  void didUpdateWidget(covariant NumberQuickScrollRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current != oldWidget.current) {
      _committed = widget.current;
    }
  }

  int _valueAt(double y, double height) {
    final trackHeight = (height - 16).clamp(0.0, double.infinity);
    final fraction = trackHeight == 0
        ? 0.0
        : ((y - 8) / trackHeight).clamp(0.0, 1.0);
    return 1 + (fraction * (widget.count - 1)).round();
  }

  void _update(Offset position, double height) {
    final value = _valueAt(position.dy, height);
    setState(() {
      _preview = value;
      _previewY = position.dy.clamp(8.0, (height - 8).clamp(8.0, height));
    });
    widget.onPreview(value);
  }

  void _commit() {
    final value = _preview;
    if (value == null) return;
    widget.onSelected(value);
    setState(() {
      _committed = value;
      _preview = null;
    });
  }

  void _cancel() {
    if (_preview != null) setState(() => _preview = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '${widget.semanticLabel} quick scroll',
      child: SizedBox(
        key: const ValueKey('number-quick-scroll-rail'),
        width: 44,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final trackHeight = (height - 16).clamp(0.0, double.infinity);
            final current = (_preview ?? _committed ?? widget.current ?? 1)
                .clamp(1, widget.count);
            final fraction = widget.count == 1
                ? 0.0
                : (current - 1) / (widget.count - 1);
            const thumbHeight = 48.0;
            final thumbTop =
                8 +
                (trackHeight - thumbHeight).clamp(0.0, double.infinity) *
                    fraction;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (details) =>
                  _update(details.localPosition, height),
              onLongPressMoveUpdate: (details) =>
                  _update(details.localPosition, height),
              onLongPressEnd: (_) => _commit(),
              onLongPressCancel: _cancel,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 10,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Positioned(
                    key: const ValueKey('number-quick-scroll-thumb'),
                    right: 10,
                    top: thumbTop,
                    child: Container(
                      width: 3,
                      height: thumbHeight,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (_preview != null)
                    Positioned(
                      key: const ValueKey('number-quick-scroll-bubble'),
                      right: 24,
                      top: (_previewY - 20).clamp(
                        0.0,
                        (height - 40).clamp(0.0, double.infinity),
                      ),
                      child: Material(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Text(
                            '${_preview!}',
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
