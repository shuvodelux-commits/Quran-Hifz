import 'package:flutter/material.dart';

/// The ornamental banner that opens a Surah in a printed Mushaf: a framed
/// bar with a light corner flourish, holding the Surah's Arabic name.
///
/// This is presentation-only chrome (no audio or tap targets), reused by
/// regular Quran reading surfaces.
class SurahNameBanner extends StatelessWidget {
  const SurahNameBanner({
    super.key,
    required this.nameArabic,
    this.subtitle,
    this.height = 52,
  });

  final String nameArabic;
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final frameColor = scheme.primary.withValues(alpha: .6);
    final fillColor = scheme.primaryContainer.withValues(alpha: .16);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _SurahBannerPainter(
              frameColor: frameColor,
              fillColor: fillColor,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: height * .8),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    nameArabic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'KFGQPC Hafs Uthmanic',
                      fontSize: height * .44,
                      height: 1,
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Draws a double-line frame with a small diamond cap on each side and a
/// light tick trim along the top/bottom edges, in the spirit of the
/// geometric borders used around a Mushaf Surah-name banner.
class _SurahBannerPainter extends CustomPainter {
  const _SurahBannerPainter({
    required this.frameColor,
    required this.fillColor,
  });

  final Color frameColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = (Offset.zero & size).deflate(1);
    final outer = RRect.fromRectAndRadius(outerRect, const Radius.circular(8));
    canvas.drawRRect(outer, Paint()..color = fillColor);

    final outerStroke = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(outer, outerStroke);

    final innerRect = RRect.fromRectAndRadius(
      outerRect.deflate(4),
      const Radius.circular(5),
    );
    final innerStroke = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    canvas.drawRRect(innerRect, innerStroke);

    final capRadius = size.height * .14;
    final capPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _drawDiamond(
      canvas,
      Offset(size.height * .55, size.height / 2),
      capRadius,
      capPaint,
    );
    _drawDiamond(
      canvas,
      Offset(size.width - size.height * .55, size.height / 2),
      capRadius,
      capPaint,
    );

    final tickPaint = Paint()
      ..color = frameColor.withValues(alpha: .55)
      ..strokeWidth = 1;
    const tickGap = 11.0;
    final tickStart = size.height * .95;
    final tickEnd = size.width - size.height * .95;
    for (var x = tickStart; x < tickEnd; x += tickGap) {
      canvas.drawLine(Offset(x, 3), Offset(x, 7), tickPaint);
      canvas.drawLine(
        Offset(x, size.height - 7),
        Offset(x, size.height - 3),
        tickPaint,
      );
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SurahBannerPainter oldDelegate) =>
      oldDelegate.frameColor != frameColor ||
      oldDelegate.fillColor != fillColor;
}
