import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/audio/offline_audio_resolver.dart';
import 'package:quran_hifz/core/database/user_database.dart';

void main() {
  test('prefers a complete non-empty local file', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    final temp = await Directory.systemTemp.createTemp('quran-audio-');
    addTearDown(() async {
      await database.close();
      await temp.delete(recursive: true);
    });
    final file = File('${temp.path}/word.mp3');
    await file.writeAsBytes([1, 2, 3]);
    await database.registerAudioSource(
      audioKey: 'word:1:1:1',
      audioType: 'word',
      remoteUrl: 'https://example.test/word.mp3',
      surahNumber: 1,
      ayahNumber: 1,
      wordPosition: 1,
    );
    await database.markAudioDownloaded(
      audioKey: 'word:1:1:1',
      localPath: file.path,
      bytes: 3,
    );

    expect(
      await OfflineAudioResolver(database).resolve('word:1:1:1'),
      file.path,
    );
  });

  test('never treats a .part file as playable offline audio', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    final temp = await Directory.systemTemp.createTemp('quran-audio-part-');
    addTearDown(() async {
      await database.close();
      await temp.delete(recursive: true);
    });
    final partial = File('${temp.path}/word.mp3.part');
    await partial.writeAsBytes([1, 2, 3]);
    await database.registerAudioSource(
      audioKey: 'word:1:1:1',
      audioType: 'word',
      remoteUrl: 'https://example.test/word.mp3',
      surahNumber: 1,
      ayahNumber: 1,
      wordPosition: 1,
    );
    await database.markAudioDownloaded(
      audioKey: 'word:1:1:1',
      localPath: partial.path,
      bytes: 3,
    );

    expect(
      await OfflineAudioResolver(database).resolve('word:1:1:1'),
      'https://example.test/word.mp3',
    );
  });
}
