import 'package:flutter/material.dart';

class SurahNameV4Text extends StatelessWidget {
  const SurahNameV4Text({
    super.key,
    required this.surahNumber,
    required this.arabicName,
    required this.style,
    this.textAlign,
  });

  final int surahNumber;
  final String arabicName;
  final TextStyle style;
  final TextAlign? textAlign;

  String get _ligature => 'surah${surahNumber.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'سورة $arabicName',
      child: ExcludeSemantics(
        child: Text(
          _ligature,
          maxLines: 1,
          textAlign: textAlign,
          style: style.copyWith(fontFamily: 'SurahNameV4'),
        ),
      ),
    );
  }
}
