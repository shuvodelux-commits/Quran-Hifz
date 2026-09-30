import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/audio/just_audio_player_adapter.dart';

void main() {
  test('ayah clip media item retains Quran background metadata', () {
    final item = buildQuranRecitationMediaItem(
      'chapter:7:1',
      title: 'Quran recitation',
    );

    expect(item.id, 'chapter:7:1');
    expect(item.album, 'YawMuslim');
    expect(item.title, 'Quran recitation');
  });
}
