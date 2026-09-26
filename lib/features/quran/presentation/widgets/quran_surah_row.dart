import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';
import 'surah_name_v4_text.dart';

class QuranSurahRow extends StatelessWidget {
  const QuranSurahRow({
    super.key,
    required this.surah,
    required this.language,
    required this.onTap,
  });

  final QuranSurahSummary surah;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final rowHeight = textScale > 1.2 ? 112.0 : 76.0;
    final metadata = language == AppLanguage.bangla
        ? '${localizedRevelationLabel(surah.revelationPlace, language)} · '
              '${localDigits('${surah.ayahCount}', language)} আয়াত'
        : '${localizedRevelationLabel(surah.revelationPlace, language)} · '
              '${surah.ayahCount} Verses';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: .55,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CustomPaint(
                    painter: _SurahMedallionPainter(
                      color: colors.outline.withValues(alpha: .65),
                    ),
                    child: Center(
                      child: Text(
                        localDigits('${surah.number}', language),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                    builder: (context, constraints) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedSurahName(surah, language),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              metadata,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: SurahNameV4Text(
                        surahNumber: surah.number,
                        arabicName: surah.nameArabic,
                        style: TextStyle(color: colors.onSurface, fontSize: 31),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String localizedRevelationLabel(String? source, AppLanguage language) {
  final normalized = source?.trim().toLowerCase();
  final isMakki = const {'makkah', 'mecca', 'makki'}.contains(normalized);
  final isMadani = const {'madinah', 'medina', 'madani'}.contains(normalized);
  if (language == AppLanguage.bangla) {
    if (isMakki) return 'মাক্কী';
    if (isMadani) return 'মাদানী';
    return 'অজানা';
  }
  if (isMakki) return 'Makki';
  if (isMadani) return 'Madani';
  return 'Unknown';
}

class _SurahMedallionPainter extends CustomPainter {
  const _SurahMedallionPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    final square = Rect.fromCenter(center: center, width: 39, height: 39);
    canvas.drawRect(square, paint);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(square, paint);
    canvas.restore();

    const sides = 8;
    final radius = size.shortestSide * .24;
    final octagon = Path();
    for (var index = 0; index < sides; index++) {
      final angle = -math.pi / 2 + index * 2 * math.pi / sides;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (index == 0) {
        octagon.moveTo(point.dx, point.dy);
      } else {
        octagon.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(octagon..close(), paint);
  }

  @override
  bool shouldRepaint(covariant _SurahMedallionPainter oldDelegate) =>
      oldDelegate.color != color;
}
