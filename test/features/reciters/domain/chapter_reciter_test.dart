import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_reciter.dart';

void main() {
  test('parses Quran Foundation chapter-reciter nested metadata', () {
    final reciter = ChapterReciter.fromJson({
      'id': 7,
      'name': 'Example Reciter',
      'style': {'name': 'Murattal', 'language_name': 'English'},
      'qirat': {'name': 'Hafs', 'language_name': 'English'},
    });

    expect(reciter.id, 7);
    expect(reciter.name, 'Example Reciter');
    expect(reciter.styleName, 'Murattal');
    expect(reciter.qiratName, 'Hafs');
  });

  test('accepts nullable metadata language labels', () {
    final reciter = ChapterReciter.fromJson({
      'id': 7,
      'name': 'Example Reciter',
      'style': {'name': null, 'language_name': null},
      'qirat': {'name': null, 'language_name': null},
    });

    expect(reciter.styleLanguageName, isNull);
    expect(reciter.qiratLanguageName, isNull);
  });

  test('rejects non-positive chapter-reciter ids', () {
    expect(
      () => ChapterReciter.fromJson({
        'id': 0,
        'name': 'Invalid',
        'style': {'name': null, 'language_name': 'English'},
        'qirat': {'name': null, 'language_name': 'English'},
      }),
      throwsFormatException,
    );
  });
}
