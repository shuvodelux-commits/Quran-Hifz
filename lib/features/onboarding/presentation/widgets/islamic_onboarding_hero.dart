import 'package:flutter/material.dart';

import '../../../../core/theme/reference_colors.dart';

class IslamicOnboardingHero extends StatelessWidget {
  const IslamicOnboardingHero({
    super.key,
    required this.icon,
    required this.arabicLine,
  });

  final IconData icon;
  final String arabicLine;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const gold = ReferenceColors.goldAccent;
    return SizedBox(
      key: const ValueKey('islamic-onboarding-hero'),
      height: 164,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicGeometryPainter(
                color: colors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                  bottomLeft: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: Icon(icon, color: colors.onPrimary, size: 28)),
                  const Positioned(
                    right: -7,
                    top: -8,
                    child: Text(
                      '✦',
                      style: TextStyle(
                        color: gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 12,
            child: Text(
              arabicLine,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: colors.primary,
                fontFamily: 'KFGQPC Hafs Uthmanic',
                fontSize: 19,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicGeometryPainter extends CustomPainter {
  const _IslamicGeometryPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final outer = Path()
      ..moveTo(size.width - 126, size.height * 0.87)
      ..lineTo(size.width - 126, size.height * 0.45)
      ..quadraticBezierTo(
        size.width - 81,
        size.height * 0.02,
        size.width - 36,
        size.height * 0.45,
      )
      ..lineTo(size.width - 36, size.height * 0.87);
    canvas.drawPath(outer, paint);

    final inner = Path()
      ..moveTo(size.width - 101, size.height * 0.87)
      ..lineTo(size.width - 101, size.height * 0.58)
      ..quadraticBezierTo(
        size.width - 81,
        size.height * 0.35,
        size.width - 61,
        size.height * 0.58,
      )
      ..lineTo(size.width - 61, size.height * 0.87);
    canvas.drawPath(inner, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicGeometryPainter oldDelegate) =>
      oldDelegate.color != color;
}
